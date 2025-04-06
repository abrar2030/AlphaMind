class MarketGAN(tf.keras.Model):
    def __init__(self, seq_length, n_features):
        super().__init__()
        self.generator = TransformerGenerator(seq_length, n_features)
        self.discriminator = TimeSeriesDiscriminator(seq_length)
        self.aux_classifier = RegimeClassifier()
        
    def compile(self, g_optimizer, d_optimizer):
        super().compile()
        self.g_optimizer = g_optimizer
        self.d_optimizer = d_optimizer
        
    def train_step(self, real_data):
        # Train discriminator
        noise = tf.random.normal((batch_size, seq_length, latent_dim))
        fake_data = self.generator(noise)
        
        real_labels = tf.ones((batch_size, 1))
        fake_labels = tf.zeros((batch_size, 1))
        
        with tf.GradientTape() as d_tape:
            real_pred = self.discriminator(real_data)
            fake_pred = self.discriminator(fake_data)
            d_loss = self.loss_fn(real_labels, real_pred) + \
                     self.loss_fn(fake_labels, fake_pred)
        
        # Train generator
        with tf.GradientTape() as g_tape:
            fake_data = self.generator(noise)
            validity = self.discriminator(fake_data)
            regime_match = self.aux_classifier(fake_data)
            g_loss = self.loss_fn(real_labels, validity) + \
                     regime_consistency_loss(regime_match)
        
        return {'d_loss': d_loss, 'g_loss': g_loss}