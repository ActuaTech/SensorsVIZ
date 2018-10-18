import java.util.Observer;


/**
* Kind of a facade to create and manage all the sensors
* @author    Guillem Francisco
* @version   0.1
*/
public class Sensors {
      private final ArrayList<Sensor> SENSORS = new ArrayList();
      private Lanes roadnetwork;
      
      /**
      * Initiate sensors facade
      * @param file  JSON file direction
      * @param client  MQTTClient in which we will add the observers
      */
      public Sensors(String file, MQTTClient client, Lanes roads) {
          roadnetwork = roads;
          load(file, client);
      }
      
      
      /**
      * Create sensors objects from JSON file and add observers to MQTTClient
      * @param file  JSON file direction
      * @param client  MQTTClient in which we will add the observers
      */
      private void load(String file, MQTTClient client){
          JSONObject object = loadJSONObject(file);
          JSONArray sensors = object.getJSONArray("sensors");
          
          for (int i = 0; i < sensors.size(); i++) {
              JSONObject sensor = sensors.getJSONObject(i);
              
              String id = sensor.getString("deviceID");
              String type = sensor.getString("type");
              JSONArray variables = sensor.getJSONArray("variables");
              String[] vrbls = {};
              
              for (int j = 0; j < variables.size(); j++){
                  vrbls = append(vrbls, variables.getString(j));
              }
              
              if(type.equals("GPSTempHum")){
                  GPSTempHum newSensor = new GPSTempHum(id, vrbls, roadnetwork);
                  SENSORS.add(newSensor);
                  client.addObserver(newSensor);
              }
          }
      }
      
      
      public void draw(Canvas canvas, int size, color c){
          for(Sensor sensor: SENSORS){
              sensor.draw(canvas, size, c);
          }
      }
}



/**
* Abstract observer object that represents a generic sensor. It has the specified varaibles and
* actualise those when a new value is collected.
* @author    Guillem Francisco
* @version   0.1
*/
public abstract class Sensor implements Observer{
  
      protected final String ID;
      protected FloatDict variablesValues = new FloatDict();
      protected final Lanes roadnetwork;
      
      
      /**
      * Initiate sensor with parameters that define itself
      * @param id  ID of the lane
      * @param variables  Variables that the sensor is gathering
      * @param roadnetwork Roads of the zone
      */
      public Sensor(String id, String[] variables, Lanes roadnetwork) {
          ID = id;
          this.roadnetwork = roadnetwork;
          createDict(variables);
      }
      
      
      /**
      * Initiate dictionary with the keys provided in the constructor
      * @param sensorVariables ArrayList with all the keys
      */
      private void createDict (String[] sensorVariables){
          for(int i = 0; i < sensorVariables.length; i++){
              variablesValues.set(sensorVariables[i], 0);
          }
      }
      
      
      /**
      * Return dictionary with variables and values of each
      * @returns variablesValues FloatDict
      */
      public FloatDict getVariablesValues(){
          return variablesValues;
      }
      
      
      /**
      * Observer update function that actualise values of the dict
      * @param obs Observable from which we are getting the data
      * @param obj Object the Observable is sending
      */
      public void update(Observable obs, Object obj){
          JSONObject payload = (JSONObject)obj;
          String sensorID = payload.getString("dev_id");
          
          if(sensorID.equals(ID)){
              JSONObject payloadFields = payload.getJSONObject("payload_fields");
              String[] dictKeys = variablesValues.keyArray();
              for(int i = 0; i< dictKeys.length; i++){
                  float value = payloadFields.getFloat(dictKeys[i]);
                  variablesValues.set(dictKeys[i], value);
              }
          }
      }
      
      
      public abstract void draw(Canvas canvas, int size, color c);
}



/**
* Extend object represents a sensor with gps, temperature and humidity variables
* @author    Guillem Francisco
* @version   0.1
*/
public class GPSTempHum extends Sensor {
  
      float rad = random(0, 20);
      boolean decreasing = true;
  
  
      /**
      * Initiate sensor with parameters that define itself
      * @param id  ID of the lane
      * @param variables  Variables that the sensor is gathering
      * @param roadnetwork Roads of the zone
      */
      public GPSTempHum(String id, String[] variables, Lanes roadnetwork){
          super(id, variables, roadnetwork);
      }
  
  
      /**
      * Observer update function that actualise values of the dict
      * and transform lat,long to X,Y
      * @param obs Observable from which we are getting the data
      * @param obj Object the Observable is sending
      */
      @Override
      public void update(Observable obs, Object obj){
          JSONObject payload = (JSONObject)obj;
          String sensorID = payload.getString("dev_id");
          
          if(sensorID.equals(ID)){
              JSONObject payloadFields = payload.getJSONObject("payload_fields");
              String[] dictKeys = variablesValues.keyArray();
              for(int i = 0; i< dictKeys.length; i++){
                  float value = payloadFields.getFloat(dictKeys[i]);
                  if(dictKeys[i].equals("lat")) value = roadnetwork.toY(value);
                  if(dictKeys[i].equals("lon")) value = roadnetwork.toX(value);
                  variablesValues.set(dictKeys[i], value);
              }
          }
      }
      
      
      /**
      * Initiate sensor with parameters that define itself
      * @param canvas  Canvas in which to draw 
      * @param size  Size of the solid point
      * @param c  Color of the point
      */
      public void draw(Canvas canvas, int size , color c){
          
          canvas.noStroke();
          canvas.fill(c);
          canvas.ellipse(variablesValues.get("lon"),variablesValues.get("lat"), size, size);
          canvas.fill(c, 100);
          canvas.ellipse(variablesValues.get("lon"),variablesValues.get("lat"), rad, rad);
          
          if(decreasing) rad = rad - 0.1;
          if(!decreasing) rad = rad + 0.1;
          if(rad < size) decreasing = false;
          if(rad > 14) decreasing = true;
      }
}
