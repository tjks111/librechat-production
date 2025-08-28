const path = require('path');
const mongoose = require(path.resolve(__dirname, '..', 'api', 'node_modules', 'mongoose'));
const { User } = require('@librechat/data-schemas').createModels(mongoose);
const { ViolationTypes } = require('librechat-data-provider');
require('module-alias')({ base: path.resolve(__dirname, '..', 'api') });
const { askQuestion, silentExit } = require('./helpers');
const { getLogStores } = require('~/cache');
const connect = require('./connect');

(async () => {
  await connect();

  console.purple('---------------------');
  console.purple('Unban a user account!');
  console.purple('---------------------');

  let email = '';

  if (process.argv.length >= 3) {
    email = process.argv[2];
  } else {
    console.orange('Usage: npm run unban-user <email>');
    console.orange('Note: if you do not pass in the email, you will be prompted for it.');
    console.purple('--------------------------');
  }

  if (!email) {
    email = await askQuestion('Email:');
  }

  if (!email.includes('@')) {
    console.red('Error: Invalid email address!');
    silentExit(1);
  }

  const user = await User.findOne({ email }).lean();
  if (!user) {
    console.red('Error: No user with that email was found!');
    silentExit(1);
  } else {
    console.purple(`Found user: ${user.email}`);
  }

  try {
    // Get ban logs store (this is the main ban cache)
    const banLogs = getLogStores(ViolationTypes.BAN);

    // Remove user ban entry
    const userId = user._id.toString();
    await banLogs.delete(userId);
    console.green(`Removed ban entry for user ${userId}`);

    // Note: IP-based bans cannot be easily removed without knowing the IP
    // The user should now be able to log in

    console.green(`Successfully unbanned user: ${email}`);
    
  } catch (error) {
    console.red('Error unbanning user:');
    console.red(error.message || error);
    console.red('Stack trace:', error.stack);
    silentExit(1);
  }

  silentExit(0);
})();

process.on('uncaughtException', (err) => {
  if (!err.message.includes('fetch failed')) {
    console.error('There was an uncaught error:');
    console.error(err);
  }

  if (err.message.includes('fetch failed')) {
    return;
  } else {
    process.exit(1);
  }
});