# react-native-timerange-picker

原生时间区间选择器组件，支持 iOS 和 Android 平台。

## 特性

- ✅ 支持 iOS (UIPickerView) 和 Android (NumberPicker)
- ✅ 5列选择器：开始小时、开始分钟、分隔符、结束小时、结束分钟
- ✅ 底部弹窗设计
- ✅ 自动验证结束时间（确保晚于开始时间）
- ✅ 完全可定制的样式
- ✅ TypeScript 支持

## 安装

```sh
npm install react-native-timerange-picker
```

或使用 yarn:

```sh
yarn add react-native-timerange-picker
```

### iOS
```sh
cd ios && pod install && cd ..
```

## 使用示例

```tsx
import { useState } from 'react';
import { View, Button } from 'react-native';
import { TimerangePickerView } from 'react-native-timerange-picker';

export default function App() {
  const [visible, setVisible] = useState(false);

  const handleConfirm = (event) => {
    const { start, end } = event.nativeEvent.time;
    console.log('选择的时间:', start, '-', end);
    setVisible(false);
  };

  return (
    <View>
      <Button title="选择时间" onPress={() => setVisible(true)} />
      
      <TimerangePickerView
        visible={visible}
        title="选择时间段"
        confirmText="确定"
        cancelText="取消"
        separatorText="至"
        selectedColor="#32C759"
        onConfirm={handleConfirm}
        onCancel={() => setVisible(false)}
      />
    </View>
  );
}
```

## API

查看完整的 API 文档：[USAGE.md](./USAGE.md)

### 主要Props

| 属性 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| `visible` | boolean | 是 | - | 控制选择器显示/隐藏 |
| `title` | string | 否 | "选择时间段" | 标题文本 |
| `confirmText` | string | 否 | "确定" | 确认按钮文本 |
| `cancelText` | string | 否 | "取消" | 取消按钮文本 |
| `separatorText` | string | 否 | "至" | 分隔符文本 |
| `selectedColor` | string | 否 | "#262626" | 选中项颜色 |
| `backgroundColor` | string | 否 | "#FFFFFF" | 背景颜色 |
| `onConfirm` | function | 否 | - | 确认回调 |
| `onCancel` | function | 否 | - | 取消回调 |


## Contributing

- [Development workflow](CONTRIBUTING.md#development-workflow)
- [Sending a pull request](CONTRIBUTING.md#sending-a-pull-request)
- [Code of conduct](CODE_OF_CONDUCT.md)

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
