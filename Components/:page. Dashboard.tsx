import AddAccountForm from '../components/AddAccountForm';

export default function Dashboard() {
  return (
    <main className="min-h-screen bg-black text-white flex flex-col items-center justify-center p-6">
      <h1 className="text-3xl font-bold text-blue-400 mb-6">🎮 Gamehub Vault</h1>
      <AddAccountForm />
    </main>
  );
}
