# procedural_audio.gd
# Generates pristine 16-bit PCM AudioStreamWAV assets dynamically.
# Ensures zero missing sound files and 100% original fantasy sound effects.
class_name ProceduralAudio
extends RefCounted

const SAMPLE_RATE: int = 22050

static func create_wav(samples: PackedFloat32Array, loop: bool = false, loop_begin: int = 0, loop_end: int = 0) -> AudioStreamWAV:
	var wav: AudioStreamWAV = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	if loop:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = loop_begin
		wav.loop_end = loop_end if loop_end > 0 else samples.size()

	var byte_array: PackedByteArray = PackedByteArray()
	byte_array.resize(samples.size() * 2)

	for i in range(samples.size()):
		var clamped: float = clampf(samples[i], -1.0, 1.0)
		var val_int: int = int(clamped * 32767.0)
		var idx: int = i * 2
		byte_array[idx] = val_int & 0xFF
		byte_array[idx + 1] = (val_int >> 8) & 0xFF

	wav.data = byte_array
	return wav

# Gate hover: soft mystical crystalline chime
static func generate_gate_hover() -> AudioStreamWAV:
	var duration: float = 0.22
	var num_samples: int = int(duration * SAMPLE_RATE)
	var samples: PackedFloat32Array = PackedFloat32Array()
	samples.resize(num_samples)

	var freq1: float = 660.0
	var freq2: float = 880.0
	for i in range(num_samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		var env: float = exp(-14.0 * t)
		var s: float = (sin(TAU * freq1 * t) * 0.6 + sin(TAU * freq2 * t) * 0.4) * env
		samples[i] = s * 0.35
	return create_wav(samples)

# Gate select: resonant elemental ignition chime
static func generate_gate_select() -> AudioStreamWAV:
	var duration: float = 0.45
	var num_samples: int = int(duration * SAMPLE_RATE)
	var samples: PackedFloat32Array = PackedFloat32Array()
	samples.resize(num_samples)

	for i in range(num_samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		var env: float = exp(-6.0 * t)
		var freq: float = 220.0 + (330.0 * exp(-12.0 * t))
		var harmonics: float = sin(TAU * freq * t) * 0.6 + sin(TAU * freq * 1.5 * t) * 0.3 + sin(TAU * freq * 2.0 * t) * 0.1
		samples[i] = harmonics * env * 0.5
	return create_wav(samples)

# Starfall: glittering cascading golden chords
static func generate_starfall() -> AudioStreamWAV:
	var duration: float = 0.9
	var num_samples: int = int(duration * SAMPLE_RATE)
	var samples: PackedFloat32Array = PackedFloat32Array()
	samples.resize(num_samples)

	var notes: Array = [523.25, 659.25, 783.99, 1046.50, 1318.51] # C5, E5, G5, C6, E6
	for i in range(num_samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		var acc: float = 0.0
		for n_idx in range(notes.size()):
			var note_time: float = t - (float(n_idx) * 0.08)
			if note_time > 0.0:
				var env: float = exp(-7.0 * note_time)
				acc += (sin(TAU * notes[n_idx] * note_time) * 0.7 + sin(TAU * notes[n_idx] * 2.0 * note_time) * 0.3) * env
		samples[i] = (acc / float(notes.size())) * 0.6
	return create_wav(samples)

# Lucky Echo: harmonic shimmering dual echo pulse
static func generate_lucky_echo() -> AudioStreamWAV:
	var duration: float = 0.7
	var num_samples: int = int(duration * SAMPLE_RATE)
	var samples: PackedFloat32Array = PackedFloat32Array()
	samples.resize(num_samples)

	var f1: float = 587.33 # D5
	var f2: float = 880.00 # A5
	for i in range(num_samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		var echo1: float = exp(-8.0 * t) * sin(TAU * f1 * t)
		var echo2: float = 0.0
		if t > 0.16:
			var t2: float = t - 0.16
			echo2 = exp(-8.0 * t2) * sin(TAU * f2 * t2) * 0.75
		samples[i] = (echo1 + echo2) * 0.45
	return create_wav(samples)

# Guardian Sigil: sacred crystalline shield chime
static func generate_guardian_sigil() -> AudioStreamWAV:
	var duration: float = 0.8
	var num_samples: int = int(duration * SAMPLE_RATE)
	var samples: PackedFloat32Array = PackedFloat32Array()
	samples.resize(num_samples)

	var freq_base: float = 440.0
	for i in range(num_samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		var env: float = exp(-5.0 * t) * (1.0 - exp(-30.0 * t))
		var shimmer: float = sin(TAU * 12.0 * t) * 0.15
		var s: float = sin(TAU * (freq_base * 1.5 + shimmer) * t) * 0.5 + sin(TAU * freq_base * 2.0 * t) * 0.4 + sin(TAU * freq_base * 3.0 * t) * 0.1
		samples[i] = s * env * 0.55
	return create_wav(samples)

# Void: ominous low-frequency cosmic vortex collapse
static func generate_void() -> AudioStreamWAV:
	var duration: float = 1.0
	var num_samples: int = int(duration * SAMPLE_RATE)
	var samples: PackedFloat32Array = PackedFloat32Array()
	samples.resize(num_samples)

	for i in range(num_samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		var env: float = exp(-3.0 * t)
		var pitch_drop: float = 180.0 * exp(-2.5 * t) + 40.0
		var noise: float = (randf() * 2.0 - 1.0) * 0.15 * (1.0 - t)
		var s: float = sin(TAU * pitch_drop * t) * 0.85 + noise
		samples[i] = s * env * 0.65
	return create_wav(samples)

# Shield block: brilliant metallic deflective clang
static func generate_shield_block() -> AudioStreamWAV:
	var duration: float = 0.6
	var num_samples: int = int(duration * SAMPLE_RATE)
	var samples: PackedFloat32Array = PackedFloat32Array()
	samples.resize(num_samples)

	for i in range(num_samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		var env: float = exp(-10.0 * t)
		var clang: float = sin(TAU * 850.0 * t) * 0.4 + sin(TAU * 1320.0 * t) * 0.35 + sin(TAU * 2400.0 * t) * 0.25
		samples[i] = clang * env * 0.7
	return create_wav(samples)

# Bank Score: celestial harp flourish
static func generate_bank() -> AudioStreamWAV:
	var duration: float = 1.0
	var num_samples: int = int(duration * SAMPLE_RATE)
	var samples: PackedFloat32Array = PackedFloat32Array()
	samples.resize(num_samples)

	var arpeggio: Array = [440.0, 554.37, 659.25, 880.0, 1108.73, 1318.51]
	for i in range(num_samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		var acc: float = 0.0
		for idx in range(arpeggio.size()):
			var note_t: float = t - (float(idx) * 0.07)
			if note_t > 0.0:
				var env: float = exp(-6.0 * note_t)
				acc += sin(TAU * arpeggio[idx] * note_t) * env
		samples[i] = (acc / float(arpeggio.size())) * 0.65
	return create_wav(samples)

# UI click
static func generate_button_click() -> AudioStreamWAV:
	var duration: float = 0.08
	var num_samples: int = int(duration * SAMPLE_RATE)
	var samples: PackedFloat32Array = PackedFloat32Array()
	samples.resize(num_samples)

	for i in range(num_samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		var env: float = exp(-40.0 * t)
		samples[i] = sin(TAU * 1100.0 * t) * env * 0.35
	return create_wav(samples)

# Ambient celestial arpeggio theme (peaceful, looping)
static func generate_ambient_loop() -> AudioStreamWAV:
	var loop_seconds: float = 12.0
	var num_samples: int = int(loop_seconds * SAMPLE_RATE)
	var samples: PackedFloat32Array = PackedFloat32Array()
	samples.resize(num_samples)

	# Chords: Am9 -> Fmaj7 -> Cmaj9 -> Em
	var chords: Array = [
		[220.0, 261.63, 329.63, 493.88], # Am9 (3 sec)
		[174.61, 261.63, 329.63, 392.00], # Fmaj7 (3 sec)
		[261.63, 329.63, 392.00, 493.88], # Cmaj7 (3 sec)
		[164.81, 246.94, 329.63, 392.00]  # Em (3 sec)
	]

	for i in range(num_samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		var chord_idx: int = int(t / 3.0) % chords.size()
		var chord_time: float = fmod(t, 3.0)
		var current_chord: Array = chords[chord_idx]

		var s: float = 0.0
		# Gentle arpeggio note every 0.375s
		var note_sub_idx: int = int(chord_time / 0.375) % current_chord.size()
		var note_freq: float = current_chord[note_sub_idx]
		var note_time: float = fmod(chord_time, 0.375)
		var note_env: float = exp(-4.0 * note_time)
		s += sin(TAU * note_freq * chord_time) * note_env * 0.25

		# Warm sub drone bass
		var bass_freq: float = current_chord[0] * 0.5
		s += sin(TAU * bass_freq * t) * 0.12

		# Ethereal pad
		for n in current_chord:
			s += sin(TAU * (n * 1.002) * t) * 0.035

		samples[i] = s * 0.25

	return create_wav(samples, true, 0, num_samples)
