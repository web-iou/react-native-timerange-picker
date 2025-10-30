import { type ViewProps } from 'react-native';
import type {
  BubblingEventHandler,
  Int32,
} from 'react-native/Libraries/Types/CodegenTypesNamespace';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
interface OnConfirmEvent {
  value: string[];
}
type Value = {
  start: string;
  end: string;
};
interface OnCancelEvent {}
interface TextStyle {
  color?: string;
  fontSize?: Int32;
  fontWeight?: Int32;
}
interface NativeProps extends ViewProps {
  visible: boolean;
  onConfirm?: BubblingEventHandler<OnConfirmEvent>;
  onCancel?: BubblingEventHandler<OnCancelEvent>;
  confirmText?: string;
  cancelText?: string;
  title?: string;
  titleStyle?: TextStyle;
  value?: Value;
  backgroundColor?: string;
  selectedColor?: string;
  confirmTextStyle?: TextStyle;
  cancelTextStyle?: TextStyle;
  separatorText?: string;
  confirmButtonColor?: string;
  cancelButtonColor?: string;
}

export default codegenNativeComponent<NativeProps>('TimerangePickerView');
