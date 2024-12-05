defmodule FinTechWeb.CashOutLiveTest do
  use FinTechWeb.ConnCase

  import Phoenix.LiveViewTest
  import FinTech.TransactionsFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_cash_out(_) do
    cash_out = cash_out_fixture()
    %{cash_out: cash_out}
  end

  describe "Index" do
    setup [:create_cash_out]

    test "lists all cash_outs", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/cash_outs")

      assert html =~ "Listing Cash outs"
    end

    test "saves new cash_out", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/cash_outs")

      assert index_live |> element("a", "New Cash out") |> render_click() =~
               "New Cash out"

      assert_patch(index_live, ~p"/cash_outs/new")

      assert index_live
             |> form("#cash_out-form", cash_out: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#cash_out-form", cash_out: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/cash_outs")

      html = render(index_live)
      assert html =~ "Cash out created successfully"
    end

    test "updates cash_out in listing", %{conn: conn, cash_out: cash_out} do
      {:ok, index_live, _html} = live(conn, ~p"/cash_outs")

      assert index_live |> element("#cash_outs-#{cash_out.id} a", "Edit") |> render_click() =~
               "Edit Cash out"

      assert_patch(index_live, ~p"/cash_outs/#{cash_out}/edit")

      assert index_live
             |> form("#cash_out-form", cash_out: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#cash_out-form", cash_out: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/cash_outs")

      html = render(index_live)
      assert html =~ "Cash out updated successfully"
    end

    test "deletes cash_out in listing", %{conn: conn, cash_out: cash_out} do
      {:ok, index_live, _html} = live(conn, ~p"/cash_outs")

      assert index_live |> element("#cash_outs-#{cash_out.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#cash_outs-#{cash_out.id}")
    end
  end

  describe "Show" do
    setup [:create_cash_out]

    test "displays cash_out", %{conn: conn, cash_out: cash_out} do
      {:ok, _show_live, html} = live(conn, ~p"/cash_outs/#{cash_out}")

      assert html =~ "Show Cash out"
    end

    test "updates cash_out within modal", %{conn: conn, cash_out: cash_out} do
      {:ok, show_live, _html} = live(conn, ~p"/cash_outs/#{cash_out}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Cash out"

      assert_patch(show_live, ~p"/cash_outs/#{cash_out}/show/edit")

      assert show_live
             |> form("#cash_out-form", cash_out: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#cash_out-form", cash_out: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/cash_outs/#{cash_out}")

      html = render(show_live)
      assert html =~ "Cash out updated successfully"
    end
  end
end
