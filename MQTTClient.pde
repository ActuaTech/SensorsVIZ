import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttCallback;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken;


/**
 * MQTT-Wrapper to simplify the use of the eclipse paho library
 * @author        Jesús García
 * @modified      Guillem Francisco
 * @version       0.1
 */
public class MQTTClient {
  
      private MqttClient client;
      private MqttConnectOptions conn = new MqttConnectOptions();
      private MemoryPersistence persistence = new MemoryPersistence();
      
      private String clientID = MqttClient.generateClientId();
    
    
      /**
      * Create Client to connect to an specified broker with a default ID and persistence
      * @param broker  URI of the broker to establish connection with
      */
      public MQTTClient(String url, String user, String password) {
          try {
            client = new MqttClient(url, clientID, persistence);
            setConnectionOptions(user, password);
          } catch (Exception e) {
            println(e);
          }
      }
    
    
      /** 
      * Set the options for the MqttConnectOptions object
      * @param user  Registered username
      * @param password  Registered password
      */
      private void setConnectionOptions(String user, String password){
          conn.setUserName(user);
          conn.setPassword(password.toCharArray());
          conn.setConnectionTimeout(20);
          conn.setKeepAliveInterval(20);
      }
      
      
      /** 
      * Try to establish connection between the Client and the broker with an username and password
      * @param user  Registered username
      * @param password  Registered password
      */
      public void connect() {
          try {
            if(!client.isConnected()) client.connect(conn);
          } catch (Exception e) {
            println(e);
          }
      }
      
      
      /**
      * Make the Client subscribe to a certain topic
      * @param topic  The desired topic to subscribe to
      */
      public void subscribe(String topic) {
          try {
            client.subscribe(topic);
          } catch (Exception e) {
            println(e);
          }
      }
    
    
      /**
      * Returns status of the connection
      * @return boolean with the status connection
      */
      public boolean getStatus() {
          return client.isConnected();
      }
    
    
      /**
      * Override MqttCallback's messageArrived method to update the corresponding LoraNode
      * Override MqttCallback's conncetionLost to try to reconnect the Client
      * @see setMessage(MqttMessage message)
      */
      public void setCallback() {
          client.setCallback(new MqttCallback() {
      
              @Override
              public void connectionLost(Throwable cause) {
                  try {
                    connect();
                  } catch (Exception e) {
                    println(e);
                  }
              }
      
              @Override
              public void messageArrived(String topic, MqttMessage message) throws Exception {
                  println(message);   //For the moment we just print the message. TODO: If this class becomes an Obserbable then notify Observers.
              }
      
              @Override
              public void deliveryComplete(IMqttDeliveryToken token){}
              
          }
          );
        }
} 
