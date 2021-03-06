"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.graphUndefinedError = void 0;
const errors_1 = require("@oclif/errors");
exports.graphUndefinedError = new errors_1.CLIError([
    "No graph found in the Apollo registry.",
    "In order to run this command, please provide a graph ID using the 'apollo.config.js' file.",
    "\n\nFor more information on configuring the Apollo CLI, please go to",
    "https://go.apollo.dev/t/config"
].join("\n"));
//# sourceMappingURL=sharedMessages.js.map