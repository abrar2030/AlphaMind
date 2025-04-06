from confluent_kafka import DeserializingConsumer
from confluent_kafka.schema_registry import SchemaRegistryClient
from confluent_kafka.schema_registry.avro import AvroDeserializer

class MarketDataPipeline:
    def __init__(self, schema_registry_url):
        self.schema_registry = SchemaRegistryClient({'url': schema_registry_url})
        self.avro_deserializer = AvroDeserializer(
            schema_registry_client=self.schema_registry,
            schema_str=market_data_schema
        )
        
        self.consumer = DeserializingConsumer({
            'bootstrap.servers': 'kafka1:9092,kafka2:9092',
            'group.id': 'quant_ai',
            'value.deserializer': self.avro_deserializer,
            'auto.offset.reset': 'earliest'
        })
        
    def process_real_time_ticks(self):
        self.consumer.subscribe(['market_data'])
        while True:
            msg = self.consumer.poll(1.0)
            if msg is None:
                continue
            if msg.error():
                raise KafkaException(msg.error())
            yield self._transform_tick(msg.value())
            
    def _transform_tick(self, raw_tick):
        return {
            'timestamp': pd.to_datetime(raw_tick['timestamp'], unit='ns'),
            'symbol': raw_tick['symbol'],
            'bid': raw_tick['bid_price'],
            'ask': raw_tick['ask_price'],
            'bid_size': raw_tick['bid_size'],
            'ask_size': raw_tick['ask_size'],
            'microstructure': self._calculate_micro_features(raw_tick)
        }