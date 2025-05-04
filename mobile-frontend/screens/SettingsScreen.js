import React, { useState } from "react";
import { StyleSheet, ScrollView, View } from "react-native";
import {
  Headline,
  Paragraph,
  List,
  Switch,
  RadioButton,
  Text,
  useTheme,
} from "react-native-paper";

export default function SettingsScreen() {
  const theme = useTheme();
  const [isNotificationsEnabled, setIsNotificationsEnabled] = useState(true);
  const [themePreference, setThemePreference] = useState("system"); // 'light', 'dark', 'system'

  const onToggleNotifications = () =>
    setIsNotificationsEnabled(!isNotificationsEnabled);

  return (
    <ScrollView
      contentContainerStyle={[
        styles.container,
        { backgroundColor: theme.colors.background },
      ]}
    >
      <Headline style={styles.title}>
        <Text>Settings</Text>
      </Headline>
      <Paragraph style={styles.paragraph}>
        <Text>Customize your app experience.</Text>
      </Paragraph>

      <List.Section title={<Text>Appearance</Text>}>
        <View style={styles.radioGroup}>
          <Text style={styles.radioLabel}>Theme</Text>
          <RadioButton.Group
            onValueChange={(newValue) => setThemePreference(newValue)}
            value={themePreference}
          >
            <View style={styles.radioButtonItem}>
              <RadioButton value="light" />
              <Text>Light</Text>
            </View>
            <View style={styles.radioButtonItem}>
              <RadioButton value="dark" />
              <Text>Dark</Text>
            </View>
            <View style={styles.radioButtonItem}>
              <RadioButton value="system" />
              <Text>System Default</Text>
            </View>
          </RadioButton.Group>
        </View>
        {/* In a real app, this themePreference would be saved and used in App.js */}
      </List.Section>

      <List.Section title={<Text>Notifications</Text>}>
        <List.Item
          title="Enable Trade Alerts"
          right={() => (
            <Switch
              value={isNotificationsEnabled}
              onValueChange={onToggleNotifications}
            />
          )}
        />
        <List.Item
          title="Enable Research Updates"
          right={() => <Switch value={true} disabled />} // Example of another setting
        />
      </List.Section>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
    padding: 20,
  },
  paragraph: {
    marginBottom: 24,
    textAlign: "center",
  },
  radioButtonItem: {
    alignItems: "center",
    flexDirection: "row",
    marginBottom: 4,
  },
  radioGroup: {
    marginBottom: 16,
    paddingHorizontal: 16,
  },
  radioLabel: {
    fontSize: 16,
    fontWeight: "bold",
    marginBottom: 8,
  },
  title: {
    marginBottom: 16,
    textAlign: "center",
  },
});
