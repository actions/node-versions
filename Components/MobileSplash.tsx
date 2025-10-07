import { useEffect } from 'react';

export default function MobileSplash({ onFinish }) {
  useEffect(() => {
    navigator.vibrate?.([200, 100, 200]);
    const ctx = new AudioContext();
    const osc = ctx.createOscillator();
    osc.type = 'triangle';
    osc.frequency.setValueAtTime(440, ctx.currentTime);
    osc.connect(ctx.destination);
    osc.start();
    osc.stop(ctx.currentTime + 0.5);
    setTimeout(onFinish, 3000);
  }, []);

  return (
    <div className="fixed inset-0 bg-black flex items-center justify-center z-50">
      <img src="/cyber-lion.gif" className="w-32 h-32 animate-bounce" />
      <h2 className="text-green-400 mt-4">در حال بارگذاری Gamehub Vault...</h2>
    </div>
  );
}
