package com.timerangepicker

import android.graphics.Color
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

  @ReactProp(name = "color")
  override fun setColor(view: TimerangePickerView?, color: String?) {
    view?.setBackgroundColor(Color.parseColor(color))
  }

  companion object {
    const val NAME = "TimerangePickerView"
  }
}
