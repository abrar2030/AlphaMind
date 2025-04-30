import React from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';

export default function DocumentationScreen() {
  return (
    <ScrollView contentContainerStyle={styles.container}>
      <Text style={styles.title}>Documentation</Text>
      <Text>Access API references, tutorials, and user guides.</Text>
      {/* Content for Documentation screen will be added here */}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 10,
  },
});

