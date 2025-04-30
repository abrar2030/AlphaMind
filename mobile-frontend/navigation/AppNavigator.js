import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import HomeScreen from '../screens/HomeScreen';
import FeaturesScreen from '../screens/FeaturesScreen';
import DocumentationScreen from '../screens/DocumentationScreen';
import ResearchScreen from '../screens/ResearchScreen';

const Tab = createBottomTabNavigator();

export default function AppNavigator() {
  return (
    <Tab.Navigator
      screenOptions={{
        headerStyle: {
          backgroundColor: '#f4511e',
        },
        headerTintColor: '#fff',
        headerTitleStyle: {
          fontWeight: 'bold',
        },
        tabBarActiveTintColor: '#f4511e',
        tabBarInactiveTintColor: 'gray',
      }}
    >
      <Tab.Screen name="Home" component={HomeScreen} options={{ title: 'AlphaMind Home' }} />
      <Tab.Screen name="Features" component={FeaturesScreen} />
      <Tab.Screen name="Docs" component={DocumentationScreen} options={{ title: 'Documentation' }} />
      <Tab.Screen name="Research" component={ResearchScreen} />
    </Tab.Navigator>
  );
}

