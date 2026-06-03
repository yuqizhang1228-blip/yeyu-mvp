// App.tsx
// ==========================================
// 应用入口 - React Native CLI 主入口
// ==========================================

import React from 'react';
import { StatusBar } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import AppNavigator from './src/navigation/AppNavigator';

const App: React.FC = () => {
  return (
    <SafeAreaProvider>
      <StatusBar barStyle="light-content" backgroundColor="transparent" translucent />
      <AppNavigator />
    </SafeAreaProvider>
  );
};

export default App;
