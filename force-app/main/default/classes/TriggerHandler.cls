public virtual with sharing class TriggerHandler {

    public void run(){

        if( TriggerOperation.BEFORE_UPDATE == Trigger.operationType ){
            this.beforeUpdate();
        }

        if( TriggerOperation.AFTER_UPDATE == Trigger.operationType ){
            this.afterUpdate();
        }
    }

    protected virtual void beforeUpdate(){
        System.debug(LoggingLevel.INFO, 'beforeUpdate');
    }

    protected virtual void afterUpdate(){
        System.debug(LoggingLevel.INFO, 'afterUpdate');
    }
}
