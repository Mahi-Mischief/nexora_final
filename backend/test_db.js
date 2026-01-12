const db = require('./db');

async function test() {
  try {
    console.log('Testing database connection...');
    const result = await db.query('SELECT NOW()');
    console.log('Database connection successful!', result.rows);
  } catch (err) {
    console.error('Database connection FAILED:', err.message);
    console.error('Error code:', err.code);
  }
  process.exit(0);
}

test();
