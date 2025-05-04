import React from "react";
import { StyleSheet, View, ScrollView, Text } from "react-native"; // Added Text import
import {
  // Surface, // Removed unused import
  Headline,
  Paragraph,
  Card,
  Title,
  useTheme,
} from "react-native-paper";
import Icon from "react-native-vector-icons/MaterialCommunityIcons";

// Mock KPI data
const kpiData = [
  {
    title: "Portfolio Value",
    value: "$1,250,345.67",
    change: "+1.2%",
    changeColor: "green",
    icon: "chart-line",
  },
  {
    title: "Daily P&L",
    value: "$15,678.90",
    change: "+0.8%",
    changeColor: "green",
    icon: "trending-up",
  },
  {
    title: "Sharpe Ratio",
    value: "2.35",
    change: "-0.05",
    changeColor: "red",
    icon: "chart-bell-curve-cumulative",
  },
  {
    title: "Active Strategies",
    value: "12",
    change: "+1",
    changeColor: "blue",
    icon: "robot",
  },
];

export default function HomeScreen() {
  const theme = useTheme();

  return (
    <ScrollView
      contentContainerStyle={[
        styles.container,
        { backgroundColor: theme.colors.background },
      ]}
    >
      <Headline style={styles.title}>
        <Text>AlphaMind Dashboard</Text>
      </Headline>
      <Paragraph style={styles.paragraph}>
        <Text>
          Real-time overview of your quantitative trading performance.
        </Text>
      </Paragraph>

      <View style={styles.kpiContainer}>
        {kpiData.map((kpi, index) => (
          <Card key={index} style={styles.kpiCard}>
            <Card.Content style={styles.kpiCardContent}>
              <Icon
                name={kpi.icon}
                size={32}
                color={theme.colors.primary}
                style={styles.kpiIcon}
              />
              <View style={styles.kpiTextContainer}>
                <Text style={styles.kpiTitle}>{kpi.title}</Text>
                <Title style={styles.kpiValue}>{kpi.value}</Title>
                <Text style={[styles.kpiChange, { color: kpi.changeColor }]}>
                  {kpi.change}
                </Text>
              </View>
            </Card.Content>
          </Card>
        ))}
      </View>

      <Paragraph style={styles.infoText}>
        <Text>
          Navigate using the bottom tabs to explore features, documentation, and
          research.
        </Text>
      </Paragraph>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
    padding: 16,
  },
  infoText: {
    color: "#888",
    marginTop: 16,
    textAlign: "center",
  },
  kpiCard: {
    width: "48%", // Approximately half width for two columns
    marginBottom: 16,
  },
  kpiCardContent: {
    alignItems: "center",
    paddingHorizontal: 8, // Reduce padding for smaller cards
    paddingVertical: 12,
  },
  kpiChange: {
    fontSize: 12,
    marginTop: 2,
  },
  kpiContainer: {
    flexDirection: "row",
    flexWrap: "wrap",
    justifyContent: "space-between",
    marginBottom: 24,
  },
  kpiIcon: {
    marginBottom: 8,
  },
  kpiTextContainer: {
    alignItems: "center",
  },
  kpiTitle: {
    color: "#666",
    fontSize: 12,
    marginBottom: 2,
    textAlign: "center",
  },
  kpiValue: {
    fontSize: 16, // Slightly smaller font for values
    lineHeight: 20,
    textAlign: "center",
  },
  paragraph: {
    fontSize: 16,
    marginBottom: 24,
    textAlign: "center",
  },
  title: {
    marginBottom: 8,
    textAlign: "center",
  },
});
