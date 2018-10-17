import java.util.Observer;


/**
* Kind of a facade to create and manage all the sensors
* @author    Guillem Francisco
* @version   0.1
*/
public class Sensors {
      private final ArrayList<Sensor> SENSORS = new ArrayList();
      
      /**
      * Initiate sensors facade
      * @param file  JSON file direction
      * @param client  MQTTClient in which we will add the observers
      */
      public Sensors(String file, MQTTClient client) {
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
              JSONArray variables = sensor.getJSONArray("variables");
              String[] vrbls = {};
              
              for (int j = 0; j < variables.size(); j++){
                  vrbls = append(vrbls, variables.getString(i));
              }
              
              Sensor newSensor = new Sensor(id, vrbls);
              
              SENSORS.add(newSensor);
              client.addObserver(newSensor);
          }
      }
}





/**
* Observer object that represents a Sensor. It has the specified varaibles and
* actualise those when a new value is collected.
* @author    Guillem Francisco
* @version   0.1
*/
public class Sensor implements Observer{
  
      private final String ID;
      private FloatDict variablesValues;
      
      
      /**
      * Initiate sensor with parameters that define itself
      * @param id  ID of the lane
      * @param variables  Variables that the sensor is gathering
      */
      public Sensor(String id, String[] variables) {
          ID = id;
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
              String[] dictKeys = variablesValues.keyArray();
              for(int i = 0; i< dictKeys.length; i++){
                  float value = payload.getFloat(dictKeys[i]);
                  variablesValues.set(dictKeys[i], value);
              }
          }
      }
}
