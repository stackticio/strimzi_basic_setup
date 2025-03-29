// Connect to the 'admin' database
db = db.getSiblingDB('admin');

// Create a new database
db = db.getSiblingDB('your_database_name');

// Create a user with readWrite permissions on the new database
db.createUser({
  user: "your_username",
  pwd: "your_password",
  roles: [{ role: "readWrite", db: "your_database_name" }]
});

// Create collections (optional)
db.createCollection('your_collection_name');

// Insert initial data into the collection (optional)
db.your_collection_name.insert({
  "key": "value",
  "another_key": "another_value"
});

print("Database setup complete");

