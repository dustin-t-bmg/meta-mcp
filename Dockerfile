# Simple production Dockerfile using pre-built files
FROM node:20-alpine

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create app directory
WORKDIR /app

# Create a non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copy the pre-built package from npm global install
COPY --chown=nodejs:nodejs build/ ./build/
COPY --chown=nodejs:nodejs package.json ./

# Install production dependencies only
RUN npm install --omit=dev --ignore-scripts && npm cache clean --force

# Change ownership
RUN chown -R nodejs:nodejs /app
USER nodejs

# Expose port (though MCP typically uses stdio)
EXPOSE 3000

# Set environment variables
ENV NODE_ENV=production

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Default command to run the MCP server
CMD ["node", "build/index.js"]
