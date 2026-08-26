const fs = require('fs');

const sampleRate = 22050;

function writeWav(file, seconds, notes, volume = 0.22) {
  const samples = Math.floor(sampleRate * seconds);
  const data = Buffer.alloc(samples * 2);
  for (let i = 0; i < samples; i += 1) {
    const time = i / sampleRate;
    const note = notes[Math.floor(time * 4) % notes.length];
    const frequency = 440 * Math.pow(2, (note - 69) / 12);
    const envelope = Math.min(1, time * 18, (seconds - time) * 12);
    const sample = Math.sin(2 * Math.PI * frequency * time) * volume * envelope;
    data.writeInt16LE(Math.max(-1, Math.min(1, sample)) * 32767, i * 2);
  }

  const header = Buffer.alloc(44);
  header.write('RIFF', 0);
  header.writeUInt32LE(36 + data.length, 4);
  header.write('WAVE', 8);
  header.write('fmt ', 12);
  header.writeUInt32LE(16, 16);
  header.writeUInt16LE(1, 20);
  header.writeUInt16LE(1, 22);
  header.writeUInt32LE(sampleRate, 24);
  header.writeUInt32LE(sampleRate * 2, 28);
  header.writeUInt16LE(2, 32);
  header.writeUInt16LE(16, 34);
  header.write('data', 36);
  header.writeUInt32LE(data.length, 40);
  fs.mkdirSync(require('path').dirname(file), { recursive: true });
  fs.writeFileSync(file, Buffer.concat([header, data]));
}

writeWav('assets/maplestory/audio/theme.wav', 8, [60, 64, 67, 72], 0.13);
writeWav('assets/maplestory/audio/action.wav', 0.45, [72, 76, 79], 0.28);
writeWav('assets/beehoney/audio/theme.wav', 8, [72, 76, 79, 84], 0.11);
writeWav('assets/beehoney/audio/collect.wav', 0.35, [79, 84, 88], 0.26);