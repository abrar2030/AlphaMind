import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

export default function FeaturesScreen() {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Features</Text>
      <Text>Explore the powerful features of AlphaMind.</Text>
      {/* Content for Features screen will be added here */}
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

