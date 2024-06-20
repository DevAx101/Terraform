import { Construct } from 'constructs';
// import { App, Chart, ChartProps, ApiObject } from 'cdk8s';
import { App, Chart, ChartProps } from 'cdk8s';

import * as kplus from 'cdk8s-plus-22';

// let redisDone = false;
// let postgresDone = false;

const POD_INSTANCES = 1;
const REDIS_POD_INSTANCES = 2;

/**
 * cat help
 * ./deploy.sh
 * kubectl get all
 */
export class MyChart extends Chart {
  constructor(scope: Construct, id: string, props: ChartProps = {}) {
    super(scope, id, props);

    // define resources here

    const APPLABEL        = 'voting-app'
    const REDISPORT       = 6379;
    const REDISIMAGE      = 'redis'
    // const REDISSVCNAME    = 'redis';

    const POSTGRESPORT    = 5432;
    const POSTGRESIMAGE   = 'postgres:9.4';
    // const POSTGRESSVCNAME = 'db';

    const VOTINGAPPPORT  = 80;
    const RESULTAPPPORT  = 80;
    // const WORKEAPPPORT   = 80;

    // const VOTINGAPPIMAGE  = 'kodekloud/examplevotingapp_vote:v1';
    // const RESULTAPPIMAGE  = 'kodekloud/examplevotingapp_result:v1';
    // const WORKEAPPIMAGE   = 'dockersamples/examplevotingapp_worker:latest';
    const VOTINGAPPIMAGE = 'bretfisher/examplevotingapp_vote:latest';
    const RESULTAPPIMAGE = 'bretfisher/examplevotingapp_result:latest';
    const WORKEAPPIMAGE  = 'bretfisher/examplevotingapp_worker:latest';
    

    /** 1. Redis */
    /* FIXME 1 */
    // const rediscontainer = new kplus.Container({
    //   image: REDISIMAGE,
    //   port:  REDISPORT
    // });
    // const redisDeploy = this.createCdk8sDeploymment(this, APPLABEL, "redisDeployment", rediscontainer, REDIS_POD_INSTANCES);
    const redisDeploy = new kplus.Deployment(this, 
      'RedisDeployment', {
      replicas: REDIS_POD_INSTANCES,
      containers: [{
        image: REDISIMAGE,
        port:  REDISPORT,
      }],
    });
    redisDeploy.metadata.addLabel('app', APPLABEL);

    /* Expose the deployment as a Load Balancer service and make it run */
    redisDeploy.exposeViaService({
      port: REDISPORT, 
      serviceType: kplus.ServiceType.LOAD_BALANCER,
    });

    // /** 2. PostgreSQL */
    /* FIXME 2 */
    // const postgresContainer = new kplus.Container({
    //   image: POSTGRESIMAGE,
    //   port: POSTGRESPORT
    // });
    // postgresContainer.addEnv('POSTGRES_USER', kplus.EnvValue.fromValue('postgres'));
    // /* use a specific key from a secret */
    // postgresContainer.addEnv('POSTGRES_PASSWORD', kplus.EnvValue.fromValue('postgres'));
    // const postgresDeploy = this.createCdk8sDeploymment(this, APPLABEL, "PostgresDeployment", postgresContainer, POD_INSTANCES);
    const postgresDeploy = new kplus.Deployment(this, 
      'PostgresDeployment', {
      replicas: POD_INSTANCES,
      containers: [{
        image: POSTGRESIMAGE,
        port:  POSTGRESPORT,
        env: {
          POSTGRES_USER:     kplus.EnvValue.fromValue('postgres'),
          POSTGRES_PASSWORD: kplus.EnvValue.fromValue('postgres')
        },
      }],
    });
    // postgresDeploy.containers[0].addEnv('POSTGRES_USER', kplus.EnvValue.fromValue('postgres'));
    // postgresDeploy.containers[0].addEnv('POSTGRES_PASSWORD', kplus.EnvValue.fromValue('postgres'));
    postgresDeploy.metadata.addLabel('app', APPLABEL);

    postgresDeploy.exposeViaService({
      port: POSTGRESPORT,
      serviceType: kplus.ServiceType.LOAD_BALANCER,
    })

    /** 3. VotingApp */
    // const votingappcontainer = new kplus.Container({
    //   image: VOTINGAPPIMAGE,
    //   port:  VOTINGAPPPORT
    // })
    // const votingAppDeploy = this.createCdk8sDeploymment(this, APPLABEL, "VotingAppDeployment", votingappcontainer, POD_INSTANCES);
    const votingAppDeploy = new kplus.Deployment(this, 
      'VotingAppDeployment', {
      replicas: POD_INSTANCES,
      containers: [{
        image: VOTINGAPPIMAGE,
        port: VOTINGAPPPORT
      }],
    });
    votingAppDeploy.metadata.addLabel('app', APPLABEL);

    votingAppDeploy.exposeViaService({
      port: VOTINGAPPPORT,
      serviceType: kplus.ServiceType.LOAD_BALANCER,
    });

    /** 4. ResultApp */
    // const resultappcontainer = new kplus.Container({
    //   image: RESULTAPPIMAGE,
    //   port:  RESULTAPPPORT
    // })
    // const resultappdeploy = this.createCdk8sDeploymment(this, APPLABEL, "ResultAppDeployment", resultappcontainer, POD_INSTANCES);
    const resultappdeploy = new kplus.Deployment(this, 
      'ResultAppDeployment', {
      replicas: POD_INSTANCES,
      containers: [{
        image: RESULTAPPIMAGE,
        port:  RESULTAPPPORT
      }],
    });
    resultappdeploy.metadata.addLabel('app', APPLABEL);

    resultappdeploy.exposeViaService({
      port: RESULTAPPPORT,
      serviceType: kplus.ServiceType.LOAD_BALANCER,
    });

    // /** 5. WorkerApp */
    // const workappcontainer = new kplus.Container({
    //   image: WORKEAPPIMAGE,
    // })
    // const workerAppDeploy = this.createCdk8sDeploymment(this, APPLABEL, "WorkerAppDeploy",workappcontainer, POD_INSTANCES)

    const workerAppDeploy = new kplus.Deployment(this, 
      'WorkerAppDeploy', {
      replicas: POD_INSTANCES,
      containers: [{
        image: WORKEAPPIMAGE,
        // port:  WORKEAPPPORT
      }],
    });
    workerAppDeploy.metadata.addLabel('app', APPLABEL);

  }

  // private createCdk8sDeploymment(chart: MyChart,
  //   label: string,
  //   deploylabel: string,
  //   container: kplus.Container,
  //   replicas: number): kplus.Deployment {

  //   const deployment = new kplus.Deployment(
  //     chart,
  //     deploylabel, {
  //       replicas: replicas
  //     })
  //   deployment.addContainer(container);
  //   deployment.metadata.addLabel('app', label);

  //   return deployment;
  // }

  // public generateObjectName(apiObject: ApiObject) {
  //   if (typeof apiObject != 'undefined') {
  //     if (typeof apiObject.metadata != 'undefined') {
  //       let override = apiObject.metadata.getLabel('overide-name')!
  //       console.log(override)
  //     }
  //   }
  //   if (typeof apiObject != 'undefined' && apiObject) {
  //     if (apiObject.kind == 'Service' && !redisDone) {
  //       redisDone = true;
  //       return "redis";
  //     }
  //     if (apiObject.kind == 'Service' && redisDone && !postgresDone) {
  //       postgresDone = true;
  //       return "db";
  //     }
  //     else {
  //       return super.generateObjectName(apiObject);
  //     }
  //   }
  //   return super.generateObjectName(apiObject);
  // }

}

const app = new App();
new MyChart(app, 'CDK8s');
app.synth();
