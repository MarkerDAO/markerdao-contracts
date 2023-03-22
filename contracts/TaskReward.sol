// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
interface IERC20 {
  function transfer(address recipient, uint256 amount) external;
  function balanceOf(address account) external view returns (uint256);
  function transferFrom(address sender, address recipient, uint256 amount) external ;
  function decimals() external view returns (uint8);
  function approve(address spender, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
}
contract TaskReward is Ownable{
    using SafeMath for uint256;
    enum TaskStatus {
        ONGOING,
        ENDED
    }
    struct Task {
        uint256     id;         //taskid
        uint256     mreward;    //reward of marker
        uint256     vreward;    //reward of validator
        uint256     freward;    //reward of fisher
        uint256     jobCount;   //pacakage count
        uint256     vround;     //number of validate round
        address     publisher;  //address of task publisher
        TaskStatus  status;
        mapping(uint256=>Job) jobs;
    }
    enum JobStatus {
        WORKING,
        SUBMITTED,
        ACCEPTED,
        REJECTED
    }
    struct Job {
        uint256     id;
        address     marker;
        address     validator;
        bool        getRewardW;
        bool        getRewardV;
        bool        getRewardF;
        JobStatus   status;
    }

    mapping(uint256=>Task) public tasks;
    uint256     public taskCount;
    address     public rewardToken;
    uint256     public fee_rate;
    // mapping(address=>uint256) public rewardPool;
    event CreateTask(
        uint256 taskId,
        uint256 mreward,
        uint256 vreward,
        uint256 freward,
        uint256 jobCount,
        uint256 vround,
        address publisher,
        uint256 pay
    );

    event AcceptTask(
        uint256 taskId,
        uint256 jobId,
        address publisher,
        address marker,
        address validator,
        address fisher,
        uint256 mreward,
        uint256 vreward,
        uint256 freward
    );

    event RejectTask(
        uint256 taskId,
        uint256 jobId,
        address publisher,
        address marker,
        address validator,
        address fisher,
        uint256 mreward,
        uint256 vreward,
        uint256 freward
    );
    constructor(address token){
        rewardToken = token;
        fee_rate = 20;
    }

    function  setRewardToekn(address token) external onlyOwner {
        rewardToken = token;
    }

    function  setFee(uint256 fee) external onlyOwner {
        fee_rate = fee;
    }

    function payForTask(uint id, uint256 mreward, uint256 vreward, uint256 freward, uint256 jobCount, uint256 vround) external {
        uint256 allPay;
        createTask(id, msg.sender, mreward, vreward, freward, jobCount, vround);
        allPay = mreward.mul(jobCount).add(vreward.mul(jobCount).mul(vround)).add(freward.mul(jobCount));
        allPay = allPay.add(allPay.mul(fee_rate).div(100));
        IERC20(rewardToken).transferFrom(msg.sender, address(this), allPay);
        // rewardPool[msg.sender] = reward.add(rewardPool[msg.sender]);
        emit CreateTask(id,  mreward,  vreward, freward,  jobCount,  vround,msg.sender, allPay);
    }

    function createTask(uint id, address publisher, uint256 mreward, uint256 vreward, uint256 freward, uint256 jobCount, uint256 vround) private{
        Task storage task = tasks[id];
        task.id = id;
        task.publisher = publisher;
        task.vreward = vreward;
        task.mreward = mreward;
        task.freward = freward;
        task.jobCount = jobCount;
        task.vround = vround;
        task.status = TaskStatus.ONGOING;
        taskCount++;

    }

    function closeTask(uint id) external {
        address publisher = tasks[id].publisher;
        if(publisher == msg.sender) {
            tasks[id].status = TaskStatus.ENDED;
        }
    }

    function acceptJob(uint256 tid, uint256 jid, address marker, address validator, address fisher) external {
        Task storage task = tasks[tid];

        if(task.publisher == msg.sender) {
            Job storage job = task.jobs[jid];
            // if( (job.status != JobStatus.ACCEPTED) && (job.status != JobStatus.REJECTED) ) {
                //don`t verify when mvp
                job.id = jid;
                job.status = JobStatus.ACCEPTED;
                job.marker = marker;
                job.validator = validator;
                IERC20(rewardToken).transfer(marker,task.mreward);
                IERC20(rewardToken).transfer(validator,task.vreward);
                IERC20(rewardToken).transfer(fisher,task.freward);
                emit AcceptTask(
                        tid,
                        jid,
                        msg.sender,
                        marker,
                        validator,
                        fisher,
                        task.mreward,
                        task.vreward,
                        task.freward
                    );
            // }
        }
    }
    
    function acceptJobs(uint256 tid, uint256[] memory jid, address[] memory marker, address[] memory validator, address[] memory fisher) external {
        Task storage task = tasks[tid];
        if(task.publisher == msg.sender) {
            uint256 jcount = jid.length;
            uint256 mcount = marker.length;
            uint256 vcount = validator.length;
            uint256 fcount = fisher.length;
            if( (jcount == mcount) && (mcount == vcount) && (mcount == fcount)) {
                for (uint256 i = 0; i < jcount; i++) {
                    Job storage job = task.jobs[jid[i]];
                    // if( (job.status != JobStatus.ACCEPTED) && (job.status != JobStatus.REJECTED) ) {
                    // don`t verify when mvp
                        job.id = jid[i];
                        job.status = JobStatus.ACCEPTED;
                        job.marker = marker[i];
                        job.validator = validator[i];
                        IERC20(rewardToken).transfer(marker[i],task.mreward);
                        IERC20(rewardToken).transfer(validator[i],task.vreward);
                        IERC20(rewardToken).transfer(fisher[i],task.freward);
                        emit AcceptTask(
                            tid,
                            jid[i],
                            msg.sender,
                            marker[i],
                            validator[i],
                            fisher[i],
                            task.mreward,
                            task.vreward,
                            task.freward
                        );
                    // }
                }
            }
        }
    }
    // function rejectJob(uint256 tid, uint256 jid,address marker,address validator) external {
    //     Task storage task = tasks[tid];
    //     if(task.publisher == msg.sender) {
    //         Job storage job = task.jobs[jid];
    //         // if( (job.status != JobStatus.ACCEPTED) && (job.status != JobStatus.REJECTED) ) {
    //         //don`t verify when mvp
    //             job.id = jid;
    //             job.status = JobStatus.REJECTED;
    //             job.marker = marker;
    //             job.validator = validator;
    //             if(msg.sender != validator) {
    //                 IERC20(rewardToken).transfer(validator,task.vreward);
    //             }
    //             emit RejectTask(
    //                     tid,
    //                     jid,
    //                     msg.sender,
    //                     marker,
    //                     validator,
    //                     task.mreward,
    //                     task.vreward
    //                 );
    //         // }
    //     }
    // }

    // function rejectJobs(uint256 tid, uint256[] memory  jid,address[] memory marker,address[] memory validator) external {
    //     Task storage task = tasks[tid];
    //     if(task.publisher == msg.sender) {
    //         uint256 jcount = jid.length;
    //         uint256 mcount = marker.length;
    //         uint256 vcount = marker.length;
    //         if( (jcount == mcount) && (mcount == vcount) ) {
    //             for (uint256 i = 0; i < jcount; i++) {
    //                 Job storage job = task.jobs[jid[i]];
    //                 // if( (job.status != JobStatus.ACCEPTED) && (job.status != JobStatus.REJECTED) ) {
    //                     //don`t verify when mvp
    //                     job.id = jid[i];
    //                     job.status = JobStatus.REJECTED;
    //                     job.marker = marker[i];
    //                     job.validator = validator[i];
    //                     if(msg.sender != validator[i]) {
    //                         IERC20(rewardToken).transfer(validator[i],task.vreward);
    //                     }
    //                     emit RejectTask(
    //                         tid,
    //                         jid[i],
    //                         msg.sender,
    //                         marker[i],
    //                         validator[i],
    //                         task.mreward,
    //                         task.vreward
    //                     );
    //                 // }
    //             }
    //         }
    //     }
    // }

    function withdraw(uint256 _amount,address _to) external onlyOwner{
        IERC20(rewardToken).transfer(_to,_amount);
    }
}
