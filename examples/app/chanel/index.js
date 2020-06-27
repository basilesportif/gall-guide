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

window.urb.poke('zod', 'chanel', 'chanel-action', {increase: {'step': 40}}, (res) => console.log(res), (err) => console.log(err));
window.urb.poke('zod', 'chanel', 'json', {increase: {step: 9}}, (res) => console.log(res), (err) => console.log(err));
