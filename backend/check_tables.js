const db = require('./db');

async function test() {
  try {
    console.log('Checking if users table exists...');
    const result = await db.query('SELECT * FROM users LIMIT 1');
    console.log('Users table exists!', result.rows);
  } catch (err) {
    console.error('Error:', err.message);
    console.error('Error code:', err.code);
    if (err.code === 'RELATION_NOT_FOUND') {
      console.log('\nUsers table does not exist! Creating it...');
      const schema = require('fs').readFileSync('../backend/sql/schema.sql', 'utf-8');
      console.log('Schema:', schema);
    }
  }
  process.exit(0);
}

test();
