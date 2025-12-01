# PawPal
Mobile Application for nonprofit, The Life of Kai

'The Life of Kai' is a non-profit organization that focuses on finding forever homes for homeless pets. We wanted to create an application that would help locate missing pets, while fostering community connections. This application will allow pet-owners to create user profiles for their pets as well as interact with other pet-owners. Reported lost pets' last locations will display on a map, along with their profile information, and other community members can also report and add markers for sightings of the lost pet.

### Sample `lost_pets` document

```json
{
	"petName": "Bella",
	"animalType": "Dog",
	"description": "Golden retriever with red collar. Last seen near Elm & 5th.",
	"latitude": 37.7749,
	"longitude": -122.4194,
	"timestamp": { "_seconds": 1732660000, "_nanoseconds": 0 },
	"photoURL": "https://firebasestorage.googleapis.com/v0/b/<project-id>/o/lost_pets%2Fabc123.jpg?alt=media",
	"reporterId": "uid_123",
	"status": "active"
}
```

> The app also understands the older `lat`/`lng` field names, so either pair works.
