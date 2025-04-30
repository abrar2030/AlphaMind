import React from 'react';
import { StyleSheet, ScrollView, Alert } from 'react-native';
import { Surface, Headline, Paragraph, List, useTheme } from 'react-native-paper';

export default function DocumentationScreen() {
  const theme = useTheme();

  const handlePress = (title) => {
    Alert.alert("Navigate", `Opening documentation for: ${title}`);
    // In a real app, you would navigate to the specific document/screen
    // e.g., navigation.navigate('DocViewer', { docId: title });
  };

  return (
    <ScrollView contentContainerStyle={[styles.container, { backgroundColor: theme.colors.background }]}>
      <Headline style={styles.title}>Documentation</Headline>
      <Paragraph style={styles.paragraph}>Access comprehensive resources to help you get the most out of AlphaMind.</Paragraph>

      <Surface style={styles.listContainer} elevation={1}>
        <List.Section title="Getting Started">
          <List.Item
            title="User Guide"
            description="Step-by-step instructions for setting up and using the platform."
            left={props => <List.Icon {...props} icon="book-open-page-variant-outline" />}
            onPress={() => handlePress('User Guide')}
          />
          <List.Item
            title="Quick Start Tutorial"
            description="A fast-paced introduction to core functionalities."
            left={props => <List.Icon {...props} icon="play-speed" />}
            onPress={() => handlePress('Quick Start Tutorial')}
          />
        </List.Section>

        <List.Section title="API Reference">
          <List.Item
            title="REST API Docs"
            description="Detailed reference for all available API endpoints."
            left={props => <List.Icon {...props} icon="api" />}
            onPress={() => handlePress('REST API Docs')}
          />
          <List.Item
            title="Python SDK"
            description="Documentation for the AlphaMind Python client library."
            left={props => <List.Icon {...props} icon="language-python" />}
            onPress={() => handlePress('Python SDK')}
          />
        </List.Section>

        <List.Section title="Examples & Tutorials">
          <List.Item
            title="Backtesting Example"
            description="Learn how to backtest trading strategies effectively."
            left={props => <List.Icon {...props} icon="chart-line" />}
            onPress={() => handlePress('Backtesting Example')}
          />
          <List.Item
            title="Model Training Tutorial"
            description="Guide on training custom AI/ML models."
            left={props => <List.Icon {...props} icon="brain" />}
            onPress={() => handlePress('Model Training Tutorial')}
          />
        </List.Section>
      </Surface>
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
  listContainer: {
    width: '100%',
    borderRadius: 8, // Optional: Add some rounding
  },
});

