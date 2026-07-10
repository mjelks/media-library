import { Controller } from "@hotwired/stimulus"

const WHEEL_CENTER = 80
const WHEEL_RADIUS = 68

const HARMONIES = {
  complementary: (h) => [h, (h + 180) % 360],
  triadic: (h) => [h, (h + 120) % 360, (h + 240) % 360],
  analogous: (h) => [h, (h + 30) % 360, (h + 330) % 360],
  monochromatic: (h) => [h]
}

// Maps every ThemeSet color attribute to a swatch derived from the picked scheme.
function buildPalette(hues, s0, l0, mode) {
  const isMono = mode === "monochromatic"
  const accent1 = hues[0]
  const accent2 = isMono ? hues[0] : (hues[1] ?? hues[0])
  const accent3 = isMono ? hues[0] : (hues[2] ?? hues[1] ?? hues[0])

  const primaryS = Math.max(s0, 55)
  const primaryBg = hsl(accent1, primaryS, isMono ? clamp(l0, 35, 55) : 50)
  const toggleBg = hsl(accent2, primaryS, isMono ? clamp(l0 - 18, 20, 70) : 48)
  const navBg = hsl(accent1, Math.min(s0, 40), 20)
  const mainBg = hsl(hues[0], clamp(s0 * 0.3, 6, 24), clamp(l0 + (isMono ? 18 : 12), 55, 78))
  const cardBg = hsl(accent3, Math.min(s0, 35), 95)
  const cardBorder = hsl(accent3, Math.min(s0, 40), 85)
  const secondaryBtnBg = hsl(hues[0], 8, 95)
  const secondaryBtnFont = hsl(hues[0], 12, 30)
  const subtitleFont = hsl(hues[0], 10, 45)
  const h1Font = hsl(accent1, Math.min(s0 + 10, 60), 18)

  return {
    main_bg_color: mainBg,
    nav_bg_color: navBg,
    nav_font_color: contrastColor(navBg),
    footer_bg_color: navBg,
    footer_font_color: contrastColor(navBg),
    h1_font_color: h1Font,
    button_primary_bg_color: primaryBg,
    button_primary_font_color: contrastColor(primaryBg),
    button_secondary_bg_color: secondaryBtnBg,
    button_secondary_font_color: secondaryBtnFont,
    toggle_active_bg_color: toggleBg,
    toggle_active_font_color: contrastColor(toggleBg),
    page_subtitle_font_color: subtitleFont,
    now_playing_card_bg_color: cardBg,
    now_playing_card_border_color: cardBorder
  }
}

function clamp(value, min, max) {
  return Math.min(Math.max(value, min), max)
}

function hsl(h, s, l) {
  h = ((h % 360) + 360) % 360
  s = clamp(s, 0, 100) / 100
  l = clamp(l, 0, 100) / 100
  const k = (n) => (n + h / 30) % 12
  const a = s * Math.min(l, 1 - l)
  const f = (n) => l - a * Math.max(-1, Math.min(k(n) - 3, Math.min(9 - k(n), 1)))
  const toHex = (n) => Math.round(255 * f(n)).toString(16).padStart(2, "0")
  return `#${toHex(0)}${toHex(8)}${toHex(4)}`
}

function hexToHsl(hex) {
  const r = parseInt(hex.slice(1, 3), 16) / 255
  const g = parseInt(hex.slice(3, 5), 16) / 255
  const b = parseInt(hex.slice(5, 7), 16) / 255
  const max = Math.max(r, g, b)
  const min = Math.min(r, g, b)
  let h = 0
  let s = 0
  const l = (max + min) / 2

  if (max !== min) {
    const d = max - min
    s = l > 0.5 ? d / (2 - max - min) : d / (max + min)
    switch (max) {
      case r: h = (g - b) / d + (g < b ? 6 : 0); break
      case g: h = (b - r) / d + 2; break
      default: h = (r - g) / d + 4; break
    }
    h *= 60
  }

  return { h: Math.round(h), s: Math.round(s * 100), l: Math.round(l * 100) }
}

function contrastColor(hex) {
  const r = parseInt(hex.slice(1, 3), 16) / 255
  const g = parseInt(hex.slice(3, 5), 16) / 255
  const b = parseInt(hex.slice(5, 7), 16) / 255
  const lin = (c) => (c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4))
  const luminance = 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)
  return luminance > 0.45 ? "#111827" : "#ffffff"
}

export default class extends Controller {
  static targets = ["wheel", "puck", "dot2", "dot3", "saturation", "lightness", "modeButtons", "swatches", "modeField", "hueField", "saturationField", "lightnessField"]
  static values = {
    hue: { type: Number, default: 210 },
    saturation: { type: Number, default: 55 },
    lightness: { type: Number, default: 50 },
    mode: { type: String, default: "complementary" },
    hasSavedScheme: { type: Boolean, default: false }
  }

  connect() {
    if (!this.hasSavedSchemeValue) {
      const seed = document.getElementById("theme_set_main_bg_color")?.value
      if (seed && /^#[0-9a-fA-F]{6}$/.test(seed)) {
        const { h, s, l } = hexToHsl(seed)
        this.hueValue = h
        this.saturationValue = clamp(s, 20, 90)
        this.lightnessValue = clamp(l, 25, 75)
      }
    }

    this.saturationTarget.value = this.saturationValue
    this.lightnessTarget.value = this.lightnessValue
    this.updateModeButtons()
    this.render()
  }

  setMode(event) {
    this.modeValue = event.currentTarget.dataset.mode
    this.updateModeButtons()
    this.render()
  }

  update() {
    this.saturationValue = Number(this.saturationTarget.value)
    this.lightnessValue = Number(this.lightnessTarget.value)
    this.render()
  }

  startDrag(event) {
    event.preventDefault()
    this.onDrag(event)
    const move = (e) => this.onDrag(e)
    const stop = () => {
      window.removeEventListener("pointermove", move)
      window.removeEventListener("pointerup", stop)
    }
    window.addEventListener("pointermove", move)
    window.addEventListener("pointerup", stop)
  }

  onDrag(event) {
    const rect = this.wheelTarget.getBoundingClientRect()
    const dx = event.clientX - (rect.left + rect.width / 2)
    const dy = event.clientY - (rect.top + rect.height / 2)
    let angle = Math.atan2(dx, -dy) * (180 / Math.PI)
    if (angle < 0) angle += 360
    this.hueValue = Math.round(angle)
    this.render()
  }

  apply() {
    const palette = buildPalette(this.hues(), this.saturationValue, this.lightnessValue, this.modeValue)
    Object.entries(palette).forEach(([attr, hexValue]) => {
      const field = document.getElementById(`theme_set_${attr}`)
      if (!field) return
      field.value = hexValue
      field.dispatchEvent(new Event("input", { bubbles: true }))
      field.dispatchEvent(new Event("change", { bubbles: true }))
    })
  }

  hues() {
    return HARMONIES[this.modeValue](this.hueValue)
  }

  updateModeButtons() {
    this.modeButtonsTarget.querySelectorAll("button").forEach((btn) => {
      const active = btn.dataset.mode === this.modeValue
      btn.classList.toggle("bg-blue-600", active)
      btn.classList.toggle("text-white", active)
      btn.classList.toggle("border-blue-600", active)
      btn.classList.toggle("bg-white", !active)
      btn.classList.toggle("text-gray-700", !active)
      btn.classList.toggle("border-gray-300", !active)
    })
  }

  render() {
    this.renderMarkers()
    this.renderSwatches()
    this.syncFields()
  }

  // Persists the generator's own state (not just the derived palette) so re-opening
  // the edit form restores the same wheel/harmony instead of reverting to defaults.
  syncFields() {
    this.modeFieldTarget.value = this.modeValue
    this.hueFieldTarget.value = this.hueValue
    this.saturationFieldTarget.value = this.saturationValue
    this.lightnessFieldTarget.value = this.lightnessValue
  }

  renderMarkers() {
    const hues = this.hues()
    this.positionMarker(this.puckTarget, this.hueValue, this.lightnessValue)

    if (hues.length > 1) {
      this.dot2Target.classList.remove("hidden")
      this.positionMarker(this.dot2Target, hues[1], 50)
    } else {
      this.dot2Target.classList.add("hidden")
    }

    if (hues.length > 2) {
      this.dot3Target.classList.remove("hidden")
      this.positionMarker(this.dot3Target, hues[2], 50)
    } else {
      this.dot3Target.classList.add("hidden")
    }
  }

  positionMarker(el, hueDeg, lightness) {
    const rad = (hueDeg * Math.PI) / 180
    const x = WHEEL_CENTER + WHEEL_RADIUS * Math.sin(rad)
    const y = WHEEL_CENTER - WHEEL_RADIUS * Math.cos(rad)
    el.style.left = `${x}px`
    el.style.top = `${y}px`
    el.style.backgroundColor = hsl(hueDeg, this.saturationValue, lightness)
  }

  renderSwatches() {
    this.swatchesTarget.innerHTML = ""
    this.hues().forEach((h) => {
      const hexValue = hsl(h, this.saturationValue, this.lightnessValue)
      const chip = document.createElement("div")
      chip.className = "w-10 h-10 rounded-md border border-gray-200 shadow-sm"
      chip.style.backgroundColor = hexValue
      chip.title = hexValue
      this.swatchesTarget.appendChild(chip)
    })
  }
}
