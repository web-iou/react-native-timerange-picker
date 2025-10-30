package com.timerangepicker

import android.graphics.Color
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.common.MapBuilder
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.TimerangePickerViewManagerInterface
import com.facebook.react.viewmanagers.TimerangePickerViewManagerDelegate

@ReactModule(name = TimerangePickerViewManager.NAME)
class TimerangePickerViewManager : SimpleViewManager<TimerangePickerView>(),
  TimerangePickerViewManagerInterface<TimerangePickerView> {
  private val mDelegate: ViewManagerDelegate<TimerangePickerView>

  init {
    mDelegate = TimerangePickerViewManagerDelegate(this)
  }

  override fun getDelegate(): ViewManagerDelegate<TimerangePickerView>? {
    return mDelegate
  }

  override fun getName(): String {
    return NAME
  }

  public override fun createViewInstance(context: ThemedReactContext): TimerangePickerView {
    return TimerangePickerView(context)
  }

  @ReactProp(name = "visible")
  override fun setVisible(view: TimerangePickerView?, visible: Boolean) {
    view?.setVisibility(visible)
  }

  @ReactProp(name = "title")
  override fun setTitle(view: TimerangePickerView?, title: String?) {
    title?.let { view?.setTitle(it) }
  }

  @ReactProp(name = "confirmText")
  override fun setConfirmText(view: TimerangePickerView?, confirmText: String?) {
    confirmText?.let { view?.setConfirmText(it) }
  }

  @ReactProp(name = "cancelText")
  override fun setCancelText(view: TimerangePickerView?, cancelText: String?) {
    cancelText?.let { view?.setCancelText(it) }
  }

  @ReactProp(name = "separatorText")
  override fun setSeparatorText(view: TimerangePickerView?, separatorText: String?) {
    separatorText?.let { view?.setSeparatorText(it) }
  }

  @ReactProp(name = "backgroundColor")
  override fun setBackgroundColor(view: TimerangePickerView?, backgroundColor: String?) {
    backgroundColor?.let { view?.setBackgroundColorValue(it) }
  }

  @ReactProp(name = "selectedColor")
  override fun setSelectedColor(view: TimerangePickerView?, selectedColor: String?) {
    selectedColor?.let { view?.setSelectedColorValue(it) }
  }

  @ReactProp(name = "confirmButtonColor")
  override fun setConfirmButtonColor(view: TimerangePickerView?, confirmButtonColor: String?) {
    confirmButtonColor?.let { view?.setConfirmButtonColorValue(it) }
  }

  @ReactProp(name = "cancelButtonColor")
  override fun setCancelButtonColor(view: TimerangePickerView?, cancelButtonColor: String?) {
    cancelButtonColor?.let { view?.setCancelButtonColorValue(it) }
  }


  @ReactProp(name = "titleStyle")
  override fun setTitleStyle(view: TimerangePickerView?, titleStyle: ReadableMap?) {
    titleStyle?.let { style ->
      val color = if (style.hasKey("color")) style.getString("color") else null
      val fontSize = if (style.hasKey("fontSize")) style.getInt("fontSize").toFloat() else null
      val fontWeight = if (style.hasKey("fontWeight")) style.getInt("fontWeight") else null
      view?.setTitleStyleValues(color, fontSize, fontWeight)
    }
  }

  @ReactProp(name = "confirmTextStyle")
  override fun setConfirmTextStyle(view: TimerangePickerView?, confirmTextStyle: ReadableMap?) {
    confirmTextStyle?.let { style ->
      val color = if (style.hasKey("color")) style.getString("color") else null
      val fontSize = if (style.hasKey("fontSize")) style.getInt("fontSize").toFloat() else null
      val fontWeight = if (style.hasKey("fontWeight")) style.getInt("fontWeight") else null
      view?.setConfirmTextStyleValues(color, fontSize, fontWeight)
    }
  }

  @ReactProp(name = "cancelTextStyle")
  override fun setCancelTextStyle(view: TimerangePickerView?, cancelTextStyle: ReadableMap?) {
    cancelTextStyle?.let { style ->
      val color = if (style.hasKey("color")) style.getString("color") else null
      val fontSize = if (style.hasKey("fontSize")) style.getInt("fontSize").toFloat() else null
      val fontWeight = if (style.hasKey("fontWeight")) style.getInt("fontWeight") else null
      view?.setCancelTextStyleValues(color, fontSize, fontWeight)
    }
  }


  override fun getExportedCustomDirectEventTypeConstants(): MutableMap<String, Any>? {
    return MapBuilder.of(
      "onConfirm", MapBuilder.of("registrationName", "onConfirm"),
      "onCancel", MapBuilder.of("registrationName", "onCancel")
    )
  }

  companion object {
    const val NAME = "TimerangePickerView"
  }
}
