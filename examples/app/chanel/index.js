console.log("fakezod");

const login =  async () => {
    const pass = 'lidlut-tabwed-pillex-ridrup';
    const res = await fetch('http://localhost/~/login', {
        method: 'POST',
        body: `password=${pass}`
    })
    console.log(res);
};

//login();

window.urb = new Channel();

window.urb.poke('zod', 'chanel', 'chanel-action', {'increase-counter': {step: 40}}, () => console.log("Successful poke"), (err) => console.log(err));
window.urb.poke('zod', 'chanel', 'chanel-action', {example: {who: 'timluc-miptev', msg: 'hello world', app: 'chanel'}}, () => console.log("Successful poke"), (err) => console.log(err));
window.urb.poke('zod', 'chanel', 'json', {'key1': 9}, () => console.log("JSON poke"), (err) => console.log(err));

// subscriptions
window.urb.subscribe('zod', 'chanel', '/example', (err) => console.log("Sub Error"), (data) => console.log(`got response: ${data}`), () => console.log("Sub Quit"));

const sendSubData = (msg) => {
    window.urb.poke('zod', 'chanel', 'chanel-action',
                    {'send-sub-data': {'path': '/example', 'msg': msg}},
                    () => 'sent', (err) => console.log(err));
};
