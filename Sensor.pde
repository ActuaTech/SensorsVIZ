import java.util.Observer;

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
      public Sensor(String id, ArrayList<String> variables) {
          ID = id;
          createDict(variables);
      }
      
      
      /**
      * Initiate dictionary with the keys provided in the constructor
      * @param sensorVariables ArrayList with all the keys
      */
      private void createDict(ArrayList<String> sensorVariables){
          for(int i = 0; i < sensorVariables.size(); i++){
              variablesValues.set(sensorVariables.get(i), 0);
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
