global class OECSyncScheduleBatch implements Schedulable {
     global void execute(SchedulableContext sc) {
        //your class which need to be call by schedular (As per your Logic)
        Database.executeBatch(new OECBatchOrderSync(),1);
     }
}