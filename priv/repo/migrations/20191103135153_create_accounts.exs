defmodule AcmeBank.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table("accounts") do
      add(:name, :string, null: false)
      add(:current_wallet_cents, :integer, null: false, default: 0)
      timestamps()
    end

    create(index("accounts", [:name], unique: true))
  end
end
