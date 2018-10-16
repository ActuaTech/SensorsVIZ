/** 
 * Import the necessary modules from paho-mqtt library
 */
import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttCallback;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken;

/** 
 * Import the necessary modules to trust the .pem certificate given by a CA
 */
import java.io.FileInputStream;
import java.io.BufferedInputStream;
import java.security.cert.CertificateFactory;
import java.security.KeyStore;
import javax.net.ssl.TrustManagerFactory;
import java.security.cert.X509Certificate;

/**
 * MQTT - Wrapper to simplify the functionality of the paho-mqtt library
 * @author        Jesús García
 * @version       0.1
 */
public class Client {
  private MqttClient mClient;
  private boolean status;
  private String clientID = MqttClient.generateClientId();
  private MqttConnectOptions conn = new MqttConnectOptions();
  private MemoryPersistence persistence = new MemoryPersistence();
  private ArrayList<LoraNode> nodes = new ArrayList<LoraNode>();

  /**
   * Create Client to connect to an specified broker with a default ID and persistence
   * @param broker  URI of the broker to establish connection with
   */
  public Client(String broker) {
    try {
      this.mClient = new MqttClient(broker, this.clientID, this.persistence);
    } 
    catch (Exception e) {
      println(e);
    }
  }

  /** 
   * Try to establish connection between the Client and the broker with an username and password
   * @param user  Registered username
   * @param password  Registered password
   */
  public void connect(String user, String password) {
    try {
      this.conn.setUserName(user);
      this.conn.setPassword(password.toCharArray());
      this.conn.setConnectionTimeout(60);
      this.conn.setKeepAliveInterval(60);
      this.mClient.connect(this.conn);

      this.status = this.mClient.isConnected();
    } 
    catch (Exception e) {
      println(e);
    }
  }

  /**
   * Prints the connection status of the Client
   */
  public void getStatus() {
    if (this.status) {
      println("Connected.");
    } else {
      println("Not connected.");
    }
  }

  /**
   * Override MqttCallback's messageArrived method to update the corresponding LoraNode
   * Override MqttCallback's conncetionLost to try to reconnect the Client
   * @see setMessage(MqttMessage message)
   */
  public void setCallback() {

    this.mClient.setCallback(new MqttCallback() {

      @Override
        public void connectionLost(Throwable cause) {
        println("Reconnecting...");
        try {
          mClient.connect(conn);
          getStatus();
        } 
        catch (Exception e) {
          println(e);
        }
      }

      @Override
        public void messageArrived(String topic, MqttMessage message) throws Exception {
        JSONObject rawData = JSONObject.parse(new String(message.getPayload()));

        String devID = rawData.getString("dev_id");

        for (LoraNode n : nodes) {
          if (devID.equals(n.getID())) {
            JSONObject decodedPayload = rawData.getJSONObject("payload_fields");
            float temp = float(decodedPayload.getInt("temperature")) / 100;
            float hum = float(decodedPayload.getInt("humidity")) / 100;
            float lat = float(str(decodedPayload.getInt("gLat1")) + str(decodedPayload.getInt("gLat2"))) / 1000000;
            float lon = float(str(decodedPayload.getInt("gLon1")) + str(decodedPayload.getInt("gLon2"))) / 1000000;
            PVector pos = new PVector(lat, lon);

            n.update(temp, hum, pos);
          }
        }
      }

      @Override
        public void deliveryComplete(IMqttDeliveryToken token) {
      }
    }
    );
  }

  /**
   * Make the Client subscribe to a certain topic
   * @param topic  The desired topic to subscribe to
   */
  public void subscribe(String topic) {
    try {
      this.mClient.subscribe(topic);
    } 
    catch (Exception e) {
      println(e);
    }
  }

  /**
   * Add a LoraNode to the internal ArrayList
   * @param n  The LoraNode to be added
   */
  public void addNode(LoraNode n) {
    this.nodes.add(n);
  }
} 
