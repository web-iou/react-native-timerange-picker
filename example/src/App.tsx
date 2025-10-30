import { useState } from 'react';
import { View, StyleSheet, Button, Text } from 'react-native';
import { TimerangePickerView } from 'react-native-timerange-picker';

export default function App() {
  const [visible, setVisible] = useState(false);
  const [timeRange, setTimeRange] = useState({ start: '', end: '' });
  const [separatorText, setSeparatorText] = useState('至');
  const [selectedColor, setSelectedColor] = useState('#262626');

  const handleConfirm = (event: any) => {
    const { start, end } = event.nativeEvent.time;
    setTimeRange({ start, end });
    // 事件已经在动画完成后触发，直接设置即可
    setVisible(false);
  };

  const handleCancel = () => {
    // 事件已经在动画完成后触发，直接设置即可
    setVisible(false);
  };

  const toggleStyle = () => {
    setSeparatorText(separatorText === '至' ? '→' : '至');
    setSelectedColor(selectedColor === '#262626' ? '#32C759' : '#262626');
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>时间区间选择器示例</Text>

      {timeRange.start && timeRange.end && (
        <View style={styles.resultContainer}>
          <Text style={styles.resultLabel}>已选择时间段：</Text>
          <Text style={styles.resultTime}>
            {timeRange.start} - {timeRange.end}
          </Text>
        </View>
      )}

      <Button title="打开时间选择器" onPress={() => setVisible(true)} />
      <Button title="切换样式" onPress={toggleStyle} />

      <TimerangePickerView
        visible={visible}
        title="选择时间段"
        confirmText="确定1"
        cancelText="取消1"
        separatorText={separatorText}
        selectedColor={selectedColor}
        onConfirm={handleConfirm}
        onCancel={handleCancel}
        backgroundColor="#FFFFFF"
        cancelButtonColor="#F0F0F0"
        confirmButtonColor='#000000'
        confirmTextStyle={{ color: '#000000', fontSize: 16, fontWeight: 500 }}
        cancelTextStyle={{ color: '#000000', fontSize: 16, fontWeight: 400 }}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#f5f5f5',
    rowGap: 10,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 30,
    color: '#333',
  },
  resultContainer: {
    backgroundColor: 'white',
    padding: 20,
    borderRadius: 10,
    marginBottom: 30,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  resultLabel: {
    fontSize: 14,
    color: '#666',
    marginBottom: 5,
  },
  resultTime: {
    fontSize: 20,
    fontWeight: '600',
    color: '#32C759',
  },
  picker: {
    width: 0,
    height: 0,
  },
});
