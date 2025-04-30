import React from 'react';
import { StyleSheet, ScrollView, Alert } from 'react-native'; // Import Alert
import { Surface, Headline, Paragraph, Card, Title, Button, useTheme } from 'react-native-paper';

export default function ResearchScreen() {
  const theme = useTheme();

  // Placeholder data for research papers
  const researchItems = [
    {
      title: 'Deep Learning for Market Prediction',
      summary: 'Exploring the efficacy of LSTM networks in forecasting short-term market movements.',
      link: '#dl-market-pred',
    },
    {
      title: 'Factor Investing with Alternative Data',
      summary: 'A study on integrating satellite imagery data into quantitative investment strategies.',
      link: '#factor-alt-data',
    },
    {
      title: 'High-Frequency Trading Algorithms',
      summary: 'Analysis of optimal execution strategies in volatile market conditions.',
      link: '#hft-algo',
    },
  ];

  const handlePress = (title, link) => {
    Alert.alert("Navigate", `Opening research paper: ${title}`);
    // In a real app, you might open a webview or navigate to a detail screen
    // e.g., Linking.openURL(link) or navigation.navigate('ResearchDetail', { paperId: link });
  };

  return (
    <ScrollView contentContainerStyle={[styles.container, { backgroundColor: theme.colors.background }]}>
      <Headline style={styles.title}>Research Insights</Headline>
      <Paragraph style={styles.paragraph}>Explore the latest publications and findings from the AlphaMind research team.</Paragraph>

      {researchItems.map((item, index) => (
        <Card key={index} style={styles.card}>
          <Card.Content>
            <Title>{item.title}</Title>
            <Paragraph>{item.summary}</Paragraph>
          </Card.Content>
          <Card.Actions>
            {/* Update onPress to call handlePress */}
            <Button onPress={() => handlePress(item.title, item.link)}>Read More</Button>
          </Card.Actions>
        </Card>
      ))}
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

