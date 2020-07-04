window.urb = new Channel();

const doShipCalls = () => {
    console.log(`window.ship: ${window.ship}`);

    window.urb.poke(window.ship, 'chanel', 'chanel-action', {'increase-counter': {step: 40}}, () => console.log("Successful poke"), (err) => console.log(err));
    window.urb.poke(window.ship, 'chanel', 'chanel-action', {example: {who: 'timluc-miptev', msg: 'hello world', app: 'chanel'}}, () => console.log("Successful poke"), (err) => console.log(err));
    window.urb.poke(window.ship, 'chanel', 'json', {'key1': 9}, () => console.log("JSON poke"), (err) => console.log(err));

    // subscriptions
    window.urb.subscribe(window.ship, 'chanel', '/example', (err) => console.log("Sub Error"), (data) => console.log(`got response: ${data}`), () => console.log("Sub Quit"));

    const sendSubData = (msg) => {
        window.urb.poke(window.ship, 'zod-action',
                        {'send-sub-data': {'path': '/example', 'msg': msg}},
                        () => 'sent', (err) => console.log(err));
    };
}

const login =  async (ship) => {
    let loginRes = await fetch('/~/login', {
        method: 'POST',
        body: `password=${passwords[ship]}`
    });
    if (loginRes.status != 200) {
        return;
    }

    const res = await fetch('/~landscape/js/session.js');
    const sessionCode = await res.text();
    eval(sessionCode);

    doShipCalls();
};

const passwords = {'zod': 'lidlut-tabwed-pillex-ridrup',
                   'timluc': 'tilhep-bittul-happex-motlet'};
Object.keys(passwords).forEach(pass => login(pass));

/*

*/
