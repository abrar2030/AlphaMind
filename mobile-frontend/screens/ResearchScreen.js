import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

export default function ResearchScreen() {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Research</Text>
      <Text>Explore the latest research from AlphaMind.</Text>
      {/* Content for Research screen will be added here */}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
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

