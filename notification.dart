//  it is necessary to set up in firebase console for notification.

dependencies :
  flutter_local_notifications: ^13.0.0
  firebase_messaging: ^14.2.2


// class that can create and display local notifications using the flutter_local_notifications package.

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
   // Settings for initializing the plugin for each platform.
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'), //  initialization settings for Android.
      iOS: DarwinInitializationSettings(), //  initialization settings for Darwin-based operating systems such as iOS and macOS
    );

    _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
      // Details of a Notification Action that was triggered.
          (NotificationResponse notificationResponse) async {
      },
    );
  }

// A class representing a message sent from Firebase Cloud Messaging.

  static void createAndDisplayNotification(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      // Contains notification details specific to each platform.

      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "pushnotificationapp",  //id
          "pushnotificationappchannel", //title
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );
      await _notificationsPlugin
          .show(
           // Show a notification with an optional payload that will be passed back to the app when a notification is tapped.
            id,
            message.notification!.title,
            message.notification!.body,
            notificationDetails,
            //  The notification can also include an optional payload, which can be accessed later when the notification is tapped.
            payload: message.data["message"]

          )
         // When this future completes with a value, the [onValue] callback will be called with that value. 
         //If this future is already completed, the callback will not be called immediately, but will be scheduled in a later microtask.
          .then((value) => print(' '));

          //An [Exception] is intended to convey information to the user about a failure, so that the error can be addressed programmatically. 
          //It is intended to be caught, and it should contain useful data fields.
    } on Exception catch (e) {
      print(e);
    }
  }
}


// To verify that your messages are being received, 
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message');
}

void main ()async{
  
// Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
// firebase_messaging to handle incoming messages from Firebase Cloud Messaging (FCM).
  FirebaseMessaging messaging = FirebaseMessaging.instance;

// Update the iOS foreground notification presentation options to allow heads up notifications.
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,// Required to display a heads up notification
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

}


initState(){
  super.initState();

      LocalNotificationService.initialize();

    // Terminated State
    // getInitialMessage() method retrieves the last received message and updates notificationMsg with its details.
    FirebaseMessaging.instance.getInitialMessage().then((event) {
      if (event != null) {
        setState(() {
          notificationMsg =
              "${event.notification!.title} ${event.notification!.body} I am coming from terminated state";
          if (notificationMsg != null) {
           // message....
          }
        });
      }
    });

    // Foregrand State
    // // If `onMessage` is triggered with a notification, construct our own
  // local notification to show to users using the created channel.
    FirebaseMessaging.onMessage.listen((event) {
      LocalNotificationService.showNotificationOnForeground(event);
      setState(() {
        notificationMsg =
            "${event.notification!.title} ${event.notification!.body} I am coming from foreground";
      });
    });

    // background State
    // Also handle any interaction when the app is in the background via a Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((notificationMsg) {
      setState(() {
        notificationMsg =
        "${event.notification!.title} ${event.notification!.body} I am coming from background";
        if (notificationMsg != null) {
          // message...
        }
      });
    });
}

