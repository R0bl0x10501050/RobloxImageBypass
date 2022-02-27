import express from 'express';
import bodyparser from 'body-parser'
import { v4 as uuidv4 } from 'uuid';
import Jimp from 'jimp';
import ejs from 'ejs';
import multer from 'multer';
import * as fs from 'fs';
import * as path from 'path';

interface Upload {
	created: number;
	data: any,
	id: string;
}

const app = express();
const upload = multer({ dest: './uploads/' });

app.set('view engine', 'ejs')
app.engine('ejs', ejs.renderFile);

app.use(bodyparser.json());
app.use(bodyparser.urlencoded({ extended: false }));

let data: Upload[] = [];

app.get('/', (req: express.Request, res: express.Response) => {
	res.render('index');
});

app.get('/:id', (req: express.Request, res: express.Response) => {
	let id = req.params.id
	let found = data.find(d => d.id === id);
	if (found) {
		res.json(found.data);
	} else {
		res.json({ error: 'Something went wrong' });
	}
});

app.post('/upload', upload.single('uploaded_file'), (req: any, res: express.Response) => {
	let img = req.file;
	Jimp.read(Buffer.from(fs.readFileSync(path.join(img.destination, img.filename))))
		.then((image) => {
			let h = image.getHeight();
			let w = image.getWidth();
			let pixels: string[] = [];

			for (let y = 0; y < h; y++) {
				for (let x = 0; x < w; x++) {
					let hex = image.getPixelColor(x, y);
					let decoded = Jimp.intToRGBA(hex);
					pixels.push(`${decoded.r}|${decoded.g}|${decoded.b}|${decoded.a}`);
				}
			}

			let uuid = uuidv4();

			data.push({
				created: Date.now(),
				data: {
					width: w,
					height: h,
					pixels: pixels
				},
				id: uuid
			});

			res.json({
				uuid: uuid
			});
		})
		.catch((error) => {
			console.error(error);
		});
});

app.listen(8080, () => {
	console.log('Online');
});
