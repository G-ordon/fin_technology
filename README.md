# **FinTech App**

The **FinTech App** is a modern mobile money system built with Elixir and Phoenix Framework, leveraging LiveView for real-time user interactions. It provides users with a secure, seamless way to manage digital wallets, transfer money, and track transactions. Inspired by platforms like M-Pesa, this app aims to facilitate cash-in, cash-out, and global transfers while maintaining KYC compliance for financial security.

---

## **Why FinTech App?**
The app addresses the need for an accessible, fast, and reliable mobile money system that works globally. It is designed to:
- Empower users to manage their finances on smartphones and feature phones (via USSD).
- Provide a robust platform for secure transactions.
- Enable global financial inclusion through its simple and effective features.

---

## **Features**

### 1. **User Registration and Authentication**
- Users can register using their email and set up a secure account.
- Authentication is handled with session tokens for enhanced security.
- Automatic session handling ensures a smooth user experience.

### 2. **Mobile Wallet Management**
- Users can maintain a balance in their wallet.
- The wallet updates dynamically after every transaction (cash-in, cash-out, transfer).

### 3. **Cash-In and Cash-Out**
- **Cash-In**: Deposit money into your wallet through an agent.
  - Fields include the deposit amount, agent ID, and agent details.
- **Cash-Out**: Withdraw money from your wallet via agents after successful authentication.

### 4. **Money Transfers**
- Transfer funds to other users using their email.
- Supports transferring to new users who aren't yet registered in the system.

### 5. **Transaction History**
- A detailed log of all transactions is available, including:
  - **Transaction Type**: Cash-in, cash-out, transfer.
  - **Amount**: The monetary value of the transaction.
  - **Timestamp**: The exact time the transaction occurred.

### 6. **KYC Implementation**
- Users must submit identification documents for verification.
- Admins review and approve the documents to ensure compliance with financial regulations.

### 7. **Real-Time Updates**
- Powered by LiveView, the app provides instantaneous updates for balances and transaction history without page reloads.

---

## **Technology Stack**

| **Component**        | **Technology**           | **Purpose**                                     |
|-----------------------|--------------------------|-------------------------------------------------|
| **Programming Language** | Elixir                  | Core backend logic                              |
| **Framework**         | Phoenix                  | Web application framework                       |
| **Frontend**          | LiveView + HEEx templates| Real-time and interactive user interface        |
| **Database**          | PostgreSQL (or SQLite)   | Stores user, wallet, and transaction data       |
| **Real-Time**         | LiveView                 | Enables live updates for UI elements            |

---

## **How to Install and Run Locally**

### Prerequisites:
1. Ensure you have **Elixir** and **Phoenix Framework** installed.
2. Install a database (PostgreSQL or SQLite).

### Steps:
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/fin_tech.git
   cd fin_tech
   ```

2. Install dependencies:
   ```bash
   mix deps.get
   ```

3. Set up the database:
   ```bash
   mix ecto.setup
   ```

4. Start the Phoenix server:
   ```bash
   mix phx.server
   ```

5. Open your browser and navigate to:
   ```
   http://localhost:4000
   ```

---

## **How to Use**

### 1. Register and Log In
- Create an account using your email.
- After logging in, you'll have access to your digital wallet.

### 2. Perform Transactions
- **Cash-In**: Deposit money into your wallet using agent details.
- **Cash-Out**: Withdraw funds securely through authenticated agents.
- **Transfer**: Send money to any email address globally.

### 3. Track Finances
- View a comprehensive transaction history to track spending and deposits.

---

## **Development Guidelines**

### Running Tests
To ensure all features work as intended, run the test suite:
```bash
mix test
```

### Adding Features
1. Create a new branch for your feature:
   ```bash
   git checkout -b feature-name
   ```
2. Implement your changes.
3. Commit your updates:
   ```bash
   git commit -m "Add feature-name"
   ```
4. Push the branch:
   ```bash
   git push origin feature-name
   ```
5. Open a Pull Request for review.

---

## **Future Features**
- Integration with popular payment gateways (e.g., PayPal, Stripe).
- USSD interface for feature phones.
- Multi-currency support for international users.

---

## **Folder Structure**

| **Folder**      | **Description**                                                |
|------------------|----------------------------------------------------------------|
| `lib/`          | Contains core application modules and logic.                   |
| `lib/fin_tech/` | Includes context modules for accounts, wallets, and transactions. |
| `test/`         | Contains unit and integration tests for the app.               |
| `assets/`       | Stores static assets for the app (CSS, JS).                    |

---

## **License**
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## **Contact**
If you have any questions or feedback, feel free to reach out at:
- **Email**: gordonochieng5454@gmil.com
- **GitHub**: @G-ordon(https://github.com/G-ordon)
