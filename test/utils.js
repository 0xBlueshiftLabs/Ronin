function getParamFromTxEvent(
    transaction,
    paramName,
    contractFactory,
    eventName
  ) {
    assert.isObject(transaction);
    let logs = transaction.logs;
    if (eventName != null) {
      logs = logs.filter((l) => l.event === eventName);
    }
    assert.equal(logs.length, 1, 'too many logs found!');
    let param = logs[0].args[paramName];
    if (contractFactory != null) {
      let contract = contractFactory.at(param);
      assert.isObject(contract, `getting ${paramName} failed for ${param}`);
      return contract;
    } else {
      return param;
    }
  }
  
  function mineBlock(web3, reject, resolve) {
    web3.currentProvider.send(
      {
        method: 'evm_mine',
        jsonrpc: '2.0',
        id: new Date().getTime(),
      },
      (e) => (e ? reject(e) : resolve())
    );
  }
  
  function increaseTimestamp(increase) {
    return new Promise((resolve, reject) => {
      web3.currentProvider.send(
        {
          method: 'evm_increaseTime',
          params: [increase],
          jsonrpc: '2.0',
          id: new Date().getTime(),
        },
        (e) => (e ? reject(e) : mineBlock(web3, reject, resolve))
      );
    });
  }
  
  async function increaseTimeTo(target) {
    let now = (await web3.eth.getBlock('latest')).timestamp;
    if (target < now)
      throw Error(
        `Cannot increase current time(${now}) to a moment in the past(${target})`
      );
    let diff = target - now;
    return increaseTimestamp(diff);
  }
  
  function balanceOf(web3, account) {
    return new Promise((resolve, reject) =>
      web3.eth.getBalance(account, (e, balance) =>
        e ? reject(e) : resolve(balance)
      )
    );
  }
  
  async function assertThrowsAsynchronously(test, error) {
    try {
      await test();
    } catch (e) {
      if (!error || e instanceof error) return 'everything is fine';
    }
    throw new Error('Missing rejection' + (error ? ' with ' + error.name : ''));
  }
  
  function latestTime() {
    return web3.eth.getBlock('latest').timestamp;
  }
  
  const duration = {
    seconds: function (val) {
      return val;
    },
    minutes: function (val) {
      return val * this.seconds(60);
    },
    hours: function (val) {
      return val * this.minutes(60);
    },
    days: function (val) {
      return val * this.hours(24);
    },
    weeks: function (val) {
      return val * this.days(7);
    },
    years: function (val) {
      return val * this.days(365);
    },
  };
  
  Object.assign(exports, {
    getParamFromTxEvent,
    increaseTimestamp,
    balanceOf,
    assertThrowsAsynchronously,
    latestTime,
    duration,
    increaseTimeTo,
  });
  