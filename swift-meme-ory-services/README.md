# Meme-Ory Services

## Reminder API module

### ReminderLoader
With ReminderStore collaborator.

#### Data
Reminder with ID

#### Retrieve Reminder
- For a given Reminder ID

#### Save Reminder

##### Primary course (happy path)
1. Delete old reminder with Reminder ID
2. Save new Reminder
3. Deliver success message

##### Delete error course (sad path)
1. Deliver delete error

##### Save error course (sad path)
1. Deliver save error

#### Delete Reminder
- With a given Reminder ID
