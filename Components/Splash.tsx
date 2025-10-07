import { useEffect } from 'react';

export default function Splash({ onFinish }) {
  useEffect(() => {
    navigator.vibrate?.([300, 100, 300]);
    const ctx = new AudioContext();
    const osc = ctx.createOscillator();
    osc.type = 'square';
    osc.frequency.setValueAtTime(660, ctx.currentTime);
    osc.connect(ctx.destination);
    osc.start();
    osc.stop(ctx.currentTime + 0.6);
    setTimeout(onFinish, 3000);
  }, []);

  return (
    <div className="fixed inset-0 bg-black flex flex-col items-center justify-center z-50">
      <img src="/cyber-lion.gif" className="w-48 h-48 animate-bounce" />
      <h2 className="text-green-400 mt-4 animate-pulse">در حال بارگذاری Gamehub Vault...</h2>
    </div>
  );
}
