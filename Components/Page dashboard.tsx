import { useEffect, useState } from 'react';

export default function Dashboard() {
  const [score, setScore] = useState(0);
  const [nfts, setNfts] = useState([]);
  const [txs, setTxs] = useState([]);

  useEffect(() => {
    fetch('/api/score').then(res => res.json()).then(data => setScore(data.points));
    fetch('/api/nfts').then(res => res.json()).then(data => setNfts(data));
    fetch('/api/txs').then(res => res.json()).then(data => setTxs(data));
  }, []);

  return (
    <div className="p-6 bg-gray-900 text-white">
      <h2 className="text-green-400 text-xl">🎖️ امتیاز: {score}</h2>
      <div className="grid grid-cols-2 gap-4 mt-4">
        {nfts.map(nft => (
          <div key={nft._id} className="bg-gray-800 p-2 rounded">
            <img src={nft.imageUrl} className="rounded mb-2" />
            <p>{nft.name}</p>
          </div>
        ))}
      </div>
      <div className="mt-6">
        <h3 className="text-blue-400">📜 تراکنش‌ها</h3>
        <ul>
          {txs.map(tx => (
            <li key={tx._id}>{tx.type} - {tx.amount} GHT - {new Date(tx.timestamp).toLocaleString()}</li>
          ))}
        </ul>
      </div>
    </div>
  );
}
