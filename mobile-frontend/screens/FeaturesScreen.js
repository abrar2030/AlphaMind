import React from 'react';
import { StyleSheet, ScrollView } from 'react-native';
import { Surface, Text, Headline, Paragraph, Card, Title, useTheme } from 'react-native-paper';

export default function FeaturesScreen() {
  const theme = useTheme();

  return (
    <ScrollView contentContainerStyle={[styles.container, { backgroundColor: theme.colors.background }]}>
      <Headline style={styles.title}>Key Features</Headline>
      <Paragraph style={styles.paragraph}>Discover the core capabilities of the AlphaMind platform.</Paragraph>

      <Card style={styles.card}>
        <Card.Content>
          <Title>AI/ML Core</Title>
          <Paragraph>Leverage advanced machine learning models for predictive analytics and strategy generation.</Paragraph>
        </Card.Content>
      </Card>

      <Card style={styles.card}>
        <Card.Content>
          <Title>Quantitative Research</Title>
          <Paragraph>Access powerful tools for backtesting, factor analysis, and portfolio optimization.</Paragraph>
        </Card.Content>
      </Card>

      <Card style={styles.card}>
        <Card.Content>
          <Title>Alternative Data Integration</Title>
          <Paragraph>Incorporate diverse datasets like satellite imagery, social media sentiment, and more.</Paragraph>
        </Card.Content>
      </Card>

      <Card style={styles.card}>
        <Card.Content>
          <Title>Risk Management</Title>
          <Paragraph>Utilize sophisticated risk models and real-time monitoring to protect capital.</Paragraph>
        </Card.Content>
      </Card>

      <Card style={styles.card}>
        <Card.Content>
          <Title>Execution Infrastructure</Title>
          <Paragraph>Connect seamlessly with brokers for low-latency order execution and management.</Paragraph>
        </Card.Content>
      </Card>

    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
    alignItems: 'center',
    padding: 20,
  },
  title: {
    marginBottom: 16,
    textAlign: 'center',
  },
  paragraph: {
    marginBottom: 24,
    textAlign: 'center',
  },
  card: {
    width: '100%',
    marginBottom: 16,
  },
});

