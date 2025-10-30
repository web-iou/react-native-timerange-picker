package com.timerangepicker

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.ObjectAnimator
import android.app.Dialog
import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.ColorDrawable
import android.util.AttributeSet
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.Window
import android.view.animation.DecelerateInterpolator
import android.widget.Button
import android.widget.LinearLayout
import android.widget.NumberPicker
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.uimanager.events.RCTEventEmitter

class TimerangePickerView : View {
    constructor(context: Context?) : super(context)
    constructor(context: Context?, attrs: AttributeSet?) : super(context, attrs)
    constructor(context: Context?, attrs: AttributeSet?, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    )

    private var dialog: Dialog? = null
    private var contentContainer: LinearLayout? = null
    private var overlayView: View? = null
    private var startHourPicker: NumberPicker? = null
    private var startMinutePicker: NumberPicker? = null
    private var endHourPicker: NumberPicker? = null
    private var endMinutePicker: NumberPicker? = null
    private var isAnimating: Boolean = false  // 防止动画被打断

    // Props
    private var isVisible: Boolean = false
    private var titleText: String = "选择时间段"
    private var confirmText: String = "确定"
    private var cancelTextString: String = "取消"
    private var separatorTextString: String = "至"
    private var backgroundColorValue: Int = Color.WHITE
    private var selectedTextColor: Int = Color.parseColor("#262626")
    private var confirmButtonColor: Int = Color.parseColor("#32C759")
    private var cancelButtonColorValue: Int = Color.parseColor("#F0F0F0")

    // Text styles
    private var titleColor: Int = Color.parseColor("#262626")
    private var titleFontSize: Float = 17f
    private var titleFontWeight: Int = Typeface.BOLD
    private var confirmTextColor: Int = Color.WHITE
    private var confirmTextFontSize: Float = 16f
    private var confirmTextFontWeight: Int = Typeface.BOLD
    private var cancelTextColor: Int = Color.DKGRAY
    private var cancelTextFontSize: Float = 16f
    private var cancelTextFontWeight: Int = Typeface.NORMAL

    // Current values
    private var startHour: Int = 9
    private var startMinute: Int = 0
    private var endHour: Int = 10
    private var endMinute: Int = 0

    fun setVisibility(visible: Boolean) {
        isVisible = visible
        if (visible) {
            showPicker()
        } else {
            // 如果正在动画中，不要重复触发关闭
            if (!isAnimating) {
                hidePicker()
            }
        }
    }

    fun setTitle(title: String) {
        titleText = title
    }

    fun setConfirmText(text: String) {
        confirmText = text
    }

    fun setCancelText(text: String) {
        cancelTextString = text
    }

    fun setSeparatorText(text: String) {
        separatorTextString = text
    }

    fun setBackgroundColorValue(color: String) {
        try {
            backgroundColorValue = Color.parseColor(color)
        } catch (e: Exception) {
            // 忽略无效颜色
        }
    }

    fun setSelectedColorValue(color: String) {
        try {
            selectedTextColor = Color.parseColor(color)
        } catch (e: Exception) {
            // 忽略无效颜色
        }
    }

    fun setConfirmButtonColorValue(color: String) {
        try {
            confirmButtonColor = Color.parseColor(color)
        } catch (e: Exception) {
            // 忽略无效颜色
        }
    }

    fun setCancelButtonColorValue(color: String) {
        try {
            cancelButtonColorValue = Color.parseColor(color)
        } catch (e: Exception) {
            // 忽略无效颜色
        }
    }

    fun setTitleStyleValues(color: String?, fontSize: Float?, fontWeight: Int?) {
        color?.let {
            try {
                titleColor = Color.parseColor(it)
            } catch (e: Exception) {
                // 忽略无效颜色
            }
        }
        fontSize?.let { titleFontSize = it }
        fontWeight?.let { titleFontWeight = mapFontWeight(it) }
    }

    fun setConfirmTextStyleValues(color: String?, fontSize: Float?, fontWeight: Int?) {
        color?.let {
            try {
                confirmTextColor = Color.parseColor(it)
            } catch (e: Exception) {
                // 忽略无效颜色
            }
        }
        fontSize?.let { confirmTextFontSize = it }
        fontWeight?.let { confirmTextFontWeight = mapFontWeight(it) }
    }

    fun setCancelTextStyleValues(color: String?, fontSize: Float?, fontWeight: Int?) {
        color?.let {
            try {
                cancelTextColor = Color.parseColor(it)
            } catch (e: Exception) {
                // 忽略无效颜色
            }
        }
        fontSize?.let { cancelTextFontSize = it }
        fontWeight?.let { cancelTextFontWeight = mapFontWeight(it) }
    }

    fun setValue(start: String?, end: String?) {
        // 解析start时间（格式：HH:MM）
        start?.let {
            val parts = it.split(":")
            if (parts.size == 2) {
                try {
                    startHour = parts[0].toInt()
                    startMinute = parts[1].toInt()
                    // 更新picker的值（如果已经显示）
                    startHourPicker?.value = startHour
                    startMinutePicker?.value = startMinute
                } catch (e: Exception) {
                    // 忽略无效格式
                }
            }
        }

        // 解析end时间（格式：HH:MM）
        end?.let {
            val parts = it.split(":")
            if (parts.size == 2) {
                try {
                    endHour = parts[0].toInt()
                    endMinute = parts[1].toInt()
                    // 更新picker的值（如果已经显示）
                    endHourPicker?.value = endHour
                    endMinutePicker?.value = endMinute
                } catch (e: Exception) {
                    // 忽略无效格式
                }
            }
        }
    }

    private fun mapFontWeight(weight: Int): Int {
        return when {
            weight >= 700 -> Typeface.BOLD
            weight >= 500 -> Typeface.BOLD  // Android 没有 medium，用 bold
            else -> Typeface.NORMAL
        }
    }

    private fun showPicker() {
        if (dialog != null && dialog!!.isShowing) {
            return
        }

        val context = context ?: return
        dialog = Dialog(context, android.R.style.Theme_Translucent_NoTitleBar)

        val window = dialog?.window ?: return
        window.setBackgroundDrawableResource(android.R.color.transparent)
        window.setLayout(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )

        // 设置全屏显示，延伸到状态栏和导航栏
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
            window.setDecorFitsSystemWindows(false)
            window.attributes.layoutInDisplayCutoutMode =
                android.view.WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
        } else {
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility = (
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
            )
        }

        // 设置状态栏和导航栏颜色
        window.statusBarColor = android.graphics.Color.TRANSPARENT
        window.navigationBarColor = backgroundColorValue
        
        // 设置导航栏为亮色模式（深色图标）
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility = window.decorView.systemUiVisibility or
                View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR
        }
        
        // 确保 window 属性生效
        window.addFlags(android.view.WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
        window.clearFlags(android.view.WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION)

        // 获取底部导航栏高度
        val bottomInset = getNavigationBarHeight(context)

        // 根容器（全屏）
        val rootLayout = android.widget.FrameLayout(context).apply {
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        }

        // 半透明遮罩层
        overlayView = View(context).apply {
            setBackgroundColor(Color.parseColor("#4D000000")) // 30%透明度的黑色
            alpha = 0f  // 初始透明
            layoutParams = android.widget.FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
            setOnClickListener {
                handleCancel()
            }
        }
        rootLayout.addView(overlayView)

        // 内容容器
        contentContainer = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            clipChildren = false
            clipToPadding = false
            layoutParams = android.widget.FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.BOTTOM
            }
        }

        // Picker内容布局
        val mainLayout = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(backgroundColorValue)
            clipChildren = false
            clipToPadding = false
            // 顶部16dp，底部 = 导航栏高度 + 24dp
            val bottomPadding = if (bottomInset > 0) bottomInset + dpToPx(24) else dpToPx(24)
            setPadding(0, dpToPx(16), 0, bottomPadding)

            // 设置顶部圆角
            val shape = android.graphics.drawable.GradientDrawable()
            shape.setColor(backgroundColorValue)
            shape.cornerRadii = floatArrayOf(
                dpToPx(16).toFloat(), dpToPx(16).toFloat(),  // 左上
                dpToPx(16).toFloat(), dpToPx(16).toFloat(),  // 右上
                0f, 0f,  // 右下
                0f, 0f   // 左下
            )
            background = shape
        }

        // 标题
        val titleView = TextView(context).apply {
            text = titleText
            textSize = titleFontSize
            setTypeface(null, titleFontWeight)
            setTextColor(titleColor)
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, dpToPx(16))
        }
        mainLayout.addView(titleView, LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        ))

        // 获取屏幕宽度
        val displayMetrics = context.resources.displayMetrics
        val screenWidth = displayMetrics.widthPixels

        // Picker容器
        val pickerContainer = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(
                screenWidth,
                dpToPx(250)
            )
        }

        // 开始小时
        startHourPicker = createNumberPicker(context, 0, 23, startHour, 0.24f)
        pickerContainer.addView(startHourPicker)

        // 开始分钟
        startMinutePicker = createNumberPicker(context, 0, 59, startMinute, 0.21f)
        pickerContainer.addView(startMinutePicker)

        // 分隔符
        val separatorView = TextView(context).apply {
            text = separatorTextString
            textSize = 16f
            setTypeface(null, Typeface.BOLD)
            setTextColor(selectedTextColor)
            gravity = Gravity.CENTER
        }
        pickerContainer.addView(separatorView, LinearLayout.LayoutParams(
            0,
            LinearLayout.LayoutParams.MATCH_PARENT,
            0.10f
        ))

        // 结束小时
        endHourPicker = createNumberPicker(context, 0, 23, endHour, 0.24f)
        pickerContainer.addView(endHourPicker)

        // 结束分钟
        endMinutePicker = createNumberPicker(context, 0, 59, endMinute, 0.21f)
        pickerContainer.addView(endMinutePicker)

        mainLayout.addView(pickerContainer)

        // 按钮容器
        val buttonContainer = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(dpToPx(20), dpToPx(20), dpToPx(20), 0)
            clipChildren = false
            clipToPadding = false
        }

        // 取消按钮
        val cancelButton = Button(context).apply {
            text = cancelTextString
            textSize = cancelTextFontSize
            setTypeface(null, cancelTextFontWeight)
            setTextColor(cancelTextColor)
            // 移除默认样式
            isAllCaps = false
            includeFontPadding = false
            setPadding(0, 0, 0, 0)
            stateListAnimator = null  // 移除默认的点击动画
            elevation = 0f
            // 设置圆角背景
            val cancelShape = android.graphics.drawable.GradientDrawable()
            cancelShape.cornerRadius = dpToPx(25).toFloat()
            cancelShape.setColor(cancelButtonColorValue)
            background = cancelShape
            setOnClickListener {
                handleCancel()
            }
        }
        buttonContainer.addView(cancelButton, LinearLayout.LayoutParams(
            0,
            dpToPx(50),
            1f
        ).apply {
            marginEnd = dpToPx(10)
        })

        // 确定按钮
        val confirmButton = Button(context).apply {
            text = confirmText
            textSize = confirmTextFontSize
            setTypeface(null, confirmTextFontWeight)
            setTextColor(confirmTextColor)
            // 移除默认样式
            isAllCaps = false
            includeFontPadding = false
            setPadding(0, 0, 0, 0)
            stateListAnimator = null  // 移除默认的点击动画
            elevation = 0f
            // 设置圆角背景
            val confirmShape = android.graphics.drawable.GradientDrawable()
            confirmShape.cornerRadius = dpToPx(25).toFloat()
            confirmShape.setColor(confirmButtonColor)
            background = confirmShape
            setOnClickListener {
                handleConfirm()
            }
        }
        buttonContainer.addView(confirmButton, LinearLayout.LayoutParams(
            0,
            dpToPx(50),
            1f
        ).apply {
            marginStart = dpToPx(10)
        })

        mainLayout.addView(buttonContainer)

        // 设置picker监听器
        setupPickerListeners()

        // 组装布局层次
        contentContainer!!.addView(mainLayout)
        rootLayout.addView(contentContainer)

        dialog?.setContentView(rootLayout)
        dialog?.setCanceledOnTouchOutside(false)  // 禁用外部点击关闭，通过遮罩层处理
        dialog?.show()

        // 显示动画
        rootLayout.viewTreeObserver.addOnGlobalLayoutListener(
            object : android.view.ViewTreeObserver.OnGlobalLayoutListener {
                override fun onGlobalLayout() {
                    rootLayout.viewTreeObserver.removeOnGlobalLayoutListener(this)

                    val contentHeight = contentContainer?.height ?: 0
                    if (contentHeight > 0) {
                        // 设置初始位置（底部外）
                        contentContainer?.translationY = contentHeight.toFloat()

                        // 立即开始动画
                        rootLayout.post {
                            // 遮罩层淡入动画
                            overlayView?.animate()
                                ?.alpha(1f)
                                ?.setDuration(300)
                                ?.setInterpolator(DecelerateInterpolator())
                                ?.start()

                            // 内容从底部滑入动画
                            contentContainer?.animate()
                                ?.translationY(0f)
                                ?.setDuration(300)
                                ?.setInterpolator(DecelerateInterpolator())
                                ?.start()
                        }
                    }
                }
            }
        )
    }

    private fun createNumberPicker(
        context: Context,
        minValue: Int,
        maxValue: Int,
        value: Int,
        weight: Float
    ): NumberPicker {
        return NumberPicker(context).apply {
            this.minValue = minValue
            this.maxValue = maxValue
            this.value = value
            wrapSelectorWheel = true
            descendantFocusability = NumberPicker.FOCUS_BLOCK_DESCENDANTS

            // 自定义显示格式
            setFormatter { value ->
                String.format("%02d", value)
            }

            layoutParams = LinearLayout.LayoutParams(
                0,
                LinearLayout.LayoutParams.MATCH_PARENT,
                weight
            )
          setNumberPickerDividerColor(this, Color.TRANSPARENT) // 透明线
        }
    }
  private fun setNumberPickerDividerColor(picker: NumberPicker, color: Int) {
    try {
      val fields = NumberPicker::class.java.declaredFields
      for (field in fields) {
        if (field.name == "mSelectionDivider") {
          field.isAccessible = true
          val colorDrawable = ColorDrawable(color)
          field.set(picker, colorDrawable)
        }
      }
    } catch (e: Exception) {
      e.printStackTrace()
    }
  }

  private fun setupPickerListeners() {
        val listener = NumberPicker.OnValueChangeListener { _, _, _ ->
            validateAndAdjustEndTime()
        }

        startHourPicker?.setOnValueChangedListener(listener)
        startMinutePicker?.setOnValueChangedListener(listener)
        endHourPicker?.setOnValueChangedListener(listener)
        endMinutePicker?.setOnValueChangedListener(listener)
    }

    private fun validateAndAdjustEndTime() {
        val startHour = startHourPicker?.value ?: return
        val startMinute = startMinutePicker?.value ?: return
        val endHour = endHourPicker?.value ?: return
        val endMinute = endMinutePicker?.value ?: return

        val startTotalMinutes = startHour * 60 + startMinute
        val endTotalMinutes = endHour * 60 + endMinute

        if (endTotalMinutes <= startTotalMinutes) {
            var newEndTotalMinutes = startTotalMinutes + 1

            if (newEndTotalMinutes >= 24 * 60) {
                newEndTotalMinutes = 23 * 60 + 59
                if (startTotalMinutes >= newEndTotalMinutes) {
                    return
                }
            }

            val newEndHour = newEndTotalMinutes / 60
            val newEndMinute = newEndTotalMinutes % 60

            endHourPicker?.value = newEndHour
            endMinutePicker?.value = newEndMinute
        }
    }

    private fun hidePicker(completion: (() -> Unit)? = null) {
        // 如果已经在动画中，忽略
        if (isAnimating) {
            completion?.invoke()
            return
        }

        val content = contentContainer
        val overlay = overlayView
        val currentDialog = dialog

        if (content == null || overlay == null || currentDialog == null || !currentDialog.isShowing) {
            dialog?.dismiss()
            dialog = null
            contentContainer = null
            overlayView = null
            completion?.invoke()
            return
        }

        // 获取内容容器的高度
        val contentHeight = content.height

        if (contentHeight <= 0) {
            // 如果高度无效，直接关闭
            currentDialog.dismiss()
            dialog = null
            contentContainer = null
            overlayView = null
            completion?.invoke()
            return
        }

        // 设置动画标志
        isAnimating = true

        // 清除之前的动画
        content.animate().cancel()
        overlay.animate().cancel()

        // 遮罩层淡出动画
        overlay.animate()
            .alpha(0f)
            .setDuration(300)
            .setInterpolator(DecelerateInterpolator())
            .start()

        // 内容滑出动画
        content.animate()
            .translationY(contentHeight.toFloat())
            .setDuration(300)
            .setInterpolator(DecelerateInterpolator())
            .setListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: Animator) {
                    isAnimating = false
                    try {
                        if (currentDialog.isShowing) {
                            currentDialog.dismiss()
                        }
                    } catch (e: Exception) {
                        // 忽略异常
                    }
                    dialog = null
                    contentContainer = null
                    overlayView = null
                    // 动画完成后执行回调
                    completion?.invoke()
                }

                override fun onAnimationCancel(animation: Animator) {
                    isAnimating = false
                    try {
                        if (currentDialog.isShowing) {
                            currentDialog.dismiss()
                        }
                    } catch (e: Exception) {
                        // 忽略异常
                    }
                    dialog = null
                    contentContainer = null
                    overlayView = null
                    // 动画取消也执行回调
                    completion?.invoke()
                }
            })
            .start()
    }

    private fun handleCancel() {
        // 在动画完成后再发送事件，避免打断动画
        hidePicker {
            val event = Arguments.createMap()
            val reactContext = context as? ReactContext
            reactContext?.getJSModule(RCTEventEmitter::class.java)
                ?.receiveEvent(id, "onCancel", event)
        }
    }

    private fun handleConfirm() {
        val startHour = startHourPicker?.value ?: this.startHour
        val startMinute = startMinutePicker?.value ?: this.startMinute
        val endHour = endHourPicker?.value ?: this.endHour
        val endMinute = endMinutePicker?.value ?: this.endMinute

        this.startHour = startHour
        this.startMinute = startMinute
        this.endHour = endHour
        this.endMinute = endMinute

        // 在动画完成后再发送事件，避免打断动画
        hidePicker {
            val valueArray = Arguments.createArray().apply {
                pushString(String.format("%02d:%02d", startHour, startMinute))
                pushString(String.format("%02d:%02d", endHour, endMinute))
            }

            val event = Arguments.createMap().apply {
                putArray("value", valueArray)
            }

            val reactContext = context as? ReactContext
            reactContext?.getJSModule(RCTEventEmitter::class.java)
                ?.receiveEvent(id, "onConfirm", event)
        }
    }

    private fun dpToPx(dp: Int): Int {
        val density = resources.displayMetrics.density
        return (dp * density).toInt()
    }

    private fun getNavigationBarHeight(context: Context): Int {
        val resources = context.resources
        val resourceId = resources.getIdentifier("navigation_bar_height", "dimen", "android")
        return if (resourceId > 0) {
            resources.getDimensionPixelSize(resourceId)
        } else {
            0
        }
    }
}
