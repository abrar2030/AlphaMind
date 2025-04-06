class TemporalFusionTransformer(tf.keras.Model):
    def __init__(self, num_encoder_steps, num_features):
        super().__init__()
        self.encoder = TransformerEncoder(num_layers=4, d_model=64)
        self.decoder = TemporalFusionDecoder(
            num_heads=8, 
            future_steps=24,
            hidden_size=32
        )
        
    def call(self, inputs):
        context = self.encoder(inputs['encoder_features'])
        predictions = self.decoder({
            'context': context,
            'decoder_features': inputs['decoder_features']
        })
        return {
            'short_term': predictions[:, :6],
            'medium_term': predictions[:, 6:18],
            'long_term': predictions[:, 18:]
        }