defmodule AcmeBank.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table("transactions") do
      add(:account_id, references("accounts", on_delete: :delete_all), null: false)
      add(:type, :string, null: false)
      add(:amount_cents, :integer, null: false)
      timestamps()
    end
  end
end
