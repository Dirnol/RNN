package edu.uco.dwilliams94.sensorcapture;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.support.wearable.activity.WearableActivity;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class MainActivity extends WearableActivity implements SensorEventListener {

    private TextView mTextView;

    private SensorManager sensorManager;
    private Sensor accelerometerSensor;

    private File accMediaStorageDir;
    private File accSensorDataFile;

    private String accWriteString = "";

    private boolean recording = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        sensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
        accelerometerSensor = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);

        mTextView = (TextView) findViewById(R.id.text);


        accMediaStorageDir = new File(this.getExternalFilesDir(null)
            + "/SensorData/Accelerometer");

        if(!accMediaStorageDir.exists()){
            accMediaStorageDir.mkdirs();
        }



        // Enables Always-on
        setAmbientEnabled();
    }

    @Override
    public void onResume(){
        super.onResume();
        sensorManager.registerListener(this, accelerometerSensor, SensorManager.SENSOR_DELAY_GAME);
    }

    @Override
    public void onPause(){
        super.onPause();
        sensorManager.unregisterListener(this);
    }

    @Override
    public void onSensorChanged(SensorEvent event) {
        if(event.accuracy == SensorManager.SENSOR_STATUS_UNRELIABLE){
            return;
        }

        if(recording){
            if(event.sensor.getType() == Sensor.TYPE_ACCELEROMETER)
                accWriteString += event.values[0] + "," + event.values[1] + "," + event.values[2] + "," + System.currentTimeMillis() + "\n";

        }
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {

    }

    public void recordSensorData(View view){

        Button recordButton = (Button) view;

        if(recording){
            recording = false;
            recordButton.setText("Record");

            try {
                FileOutputStream accStream = new FileOutputStream(accSensorDataFile);
                accStream.write(accWriteString.getBytes());
                accStream.close();
            } catch (FileNotFoundException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            }
            accWriteString = "";

        }else{
            recording = true;
            recordButton.setText("Stop Recording");
            SimpleDateFormat simpleDateFormat = new SimpleDateFormat("dd-MM-yyyy-hh-mm-ss");
            String format = simpleDateFormat.format(new Date());
            accSensorDataFile = new File(accMediaStorageDir, "SensorData-" + format + ".dat");
            try {
                accSensorDataFile.createNewFile();
            } catch (IOException ex) {
                ex.printStackTrace();
            }
        }
    }
}
