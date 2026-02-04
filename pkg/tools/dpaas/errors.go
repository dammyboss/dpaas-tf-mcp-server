package tools

import (
	"fmt"

	"github.com/mark3labs/mcp-go/mcp"
	log "github.com/sirupsen/logrus"
)

// DPaaSToolError wraps an error into an MCP tool-result error with [dpaas] prefix logging.
func DPaaSToolError(logger *log.Logger, message string, err error) (*mcp.CallToolResult, error) {
	fullMessage := message
	if err != nil {
		fullMessage = fmt.Sprintf("%s: %v", message, err)
	}
	if logger != nil {
		logger.Errorf("[dpaas] %s", fullMessage)
	}
	return mcp.NewToolResultError(fullMessage), nil
}

// DPaaSToolErrorf is the formatted variant of DPaaSToolError.
func DPaaSToolErrorf(logger *log.Logger, format string, args ...interface{}) (*mcp.CallToolResult, error) {
	message := fmt.Sprintf(format, args...)
	if logger != nil {
		logger.Errorf("[dpaas] %s", message)
	}
	return mcp.NewToolResultError(message), nil
}
